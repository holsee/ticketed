defmodule Ticketed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Ecto repository
        Ticketed.Repo,
        # Start the Telemetry supervisor
        TicketedWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: Ticketed.PubSub},
        # Start the Endpoint (http/https)
        TicketedWeb.Endpoint
      ] ++
        if Mix.env() != :test do
          [
            # Start Bookings ingestion
            Ticketed.BookingsPipeline
          ]
        else
          []
        end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ticketed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TicketedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
