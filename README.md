# Ticketed  🎟 

A more complete example of using Broadway with a RabbitMQ produced within and Phoenix 1.6 
application which includes leveraging Ecto & Swoosh (email) w/ unit tests for a slightly 
more realistic implementation.

For the accompanying book from which this demo was inspired see:
[Concurrent Data Processing in Elixir by Svilen Gospodinov](https://pragprog.com/titles/sgdpelixir/concurrent-data-processing-in-elixir/)

## Getting started

### Configure RabbitMQ

Create a `config/dev.env` file with the following completed:
```bash
export TICKETED_MQ_HOST="somerandomstring.mq.us-east-1.amazonaws.com"
export TICKETED_MQ_PORT=5671
export TICKETED_MQ_QUEUE="ticketed"
export TICKETED_MQ_USERNAME="a-username"
export TICKETED_MQ_PASSWORD="some-password"
```

ℹ️  For this demo I have used secure connections `amqps://`.


To disable SSL you can edit the connection code in the `BuildPipeline` 
for the RabbitMQ producer by removing the `ssl_options`.

Within the `.iex.exs` the `send_messages/1` helper uses `AMQP` directly, 
change `amqps://` to `amqp://`.

### Setup & Run App

Grab deps
``` sh
$ mix do deps.get, compile
$ source config/dev.env
```

Run tests
```sh
$ mix test
```

Run app
``` sh
$ mix ecto.reset
$ iex -S mix phx.server
```

Fire a bunch of messages onto your RabbitMQ 🐰
```elixir
iex> send_messages.(10)
```

## Dashboards

### Phoenix Dashboard

```sh
open http://localhost:4000/dev/dashboard
```

Ecto & PSQL Dashboard:
```sh
$ open http://localhost:4000/dev/dashboard/ecto_stats
```

Broadway Processing Pipeline Dashboard:
```sh
$ open http://localhost:4000/dev/dashboard/broadway?nav=BookingsPipeline
```

### Email Mailbox (dev)

View Emails using Swoosh test Mailbox:
```bash
$ open http://localhost:4000/dev/mailbox
```
