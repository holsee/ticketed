defmodule Ticketed.BookingsPipeline do
  use Broadway

  @producer BroadwayRabbitMQ.Producer

  def start_link(_args) do
    producer_config = [
      queue: System.get_env("TICKETED_MQ_QUEUE"),
      connection: [
        host: System.get_env("TICKETED_MQ_HOST"),
        port: System.get_env("TICKETED_MQ_PORT") |> String.to_integer(),
        username: System.get_env("TICKETED_MQ_USERNAME"),
        password: System.get_env("TICKETED_MQ_PASSWORD"),
        ssl_options: [
          fail_if_no_peer_cert: false
        ]
      ],
      declare: [durable: true],
      on_failure: :reject_and_requeue,
      qos: [
        prefetch_count: 10_000
      ]
    ]

    options = [
      name: BookingsPipeline,
      producer: [module: {@producer, producer_config}],
      processors: [
        default: []
      ],
      batchers: [
        default: [
          concurrency: 10,
          batch_size: 1000
        ]
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  @impl Broadway
  def handle_batch(_batcher, messages, batch_info, _context) do
    IO.puts(
      "#{inspect(self())} Batch #{batch_info.size} #{batch_info.batcher} #{batch_info.batch_key}"
    )

    {:ok, _tickets} =
      messages
      |> Enum.map(& &1.data)
      |> Ticketed.insert_all_tickets()

    messages
    |> Enum.map(fn %_{data: %{event: event, user: user}} ->
      Ticketed.send_confirmation_email(user, event)
    end)

    messages
  end

  @impl Broadway
  def prepare_messages(messages, _context) do
    # Decode message
    messages =
      Enum.map(messages, fn message ->
        Broadway.Message.update_data(message, fn data ->
          [event_id, user_id] = String.split(data, ",") |> Enum.map(&String.to_integer/1)
          %{event_id: event_id, user_id: user_id}
        end)
      end)

    # Load users and events in bulk 
    user_ids = Enum.map(messages, & &1.data.user_id)
    users = Ticketed.get_users_by_ids(user_ids)

    event_ids = Enum.map(messages, & &1.data.event_id)
    events = Ticketed.get_events_by_ids(event_ids)

    # Put users and events into message
    Enum.map(messages, fn message ->
      Broadway.Message.update_data(message, fn data ->
        Map.merge(data, %{
          event: Map.get(events, data.event_id),
          user: Map.get(users, data.user_id)
        })
      end)
    end)
  end

  @impl Broadway
  def handle_message(_processor, message, _context) do
    %_{data: %{event: event}} = message

    if Ticketed.tickets_available?(event) do
      message
    else
      Broadway.Message.failed(message, "sold-out")
    end
  end

  @impl Broadway
  def handle_failed(messages, _context) do
    # IO.inspect(messages, label: "Failed messages")

    Enum.map(messages, fn
      %{status: {:failed, "sold-out"}} = message ->
        Broadway.Message.configure_ack(message, on_failure: :reject)

      message ->
        message
    end)
  end
end
