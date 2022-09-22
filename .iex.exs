send_messages = fn message_count ->
  queue = System.get_env("TICKETED_MQ_QUEUE")
  host = System.get_env("TICKETED_MQ_HOST")
  port = System.get_env("TICKETED_MQ_PORT") |> String.to_integer()
  username = System.get_env("TICKETED_MQ_USERNAME")
  password = System.get_env("TICKETED_MQ_PASSWORD")
  url = "amqps://#{username}:#{password}@#{host}:#{port}"

  {:ok, conn} = AMQP.Connection.open(url)
  {:ok, channel} = AMQP.Channel.open(conn)

  import Ecto.Query
  alias Ticketed.{Repo, Events.Event, Users.User}

  event_count = Repo.one!(from e in Event, select: max(e.id))
  user_count = Repo.one!(from u in User, select: max(u.id))

  Enum.each(1..message_count, fn _ ->
    event_id = Enum.random(1..event_count)
    user_id = Enum.random(1..user_count)

    AMQP.Basic.publish(channel, "", queue, "#{event_id},#{user_id}")
  end)
end
