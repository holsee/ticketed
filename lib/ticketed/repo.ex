defmodule Ticketed.Repo do
  use Ecto.Repo,
    otp_app: :ticketed,
    adapter: Ecto.Adapters.Postgres
end
