defmodule Ticketed.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :event_id, references(:events, on_delete: :restrict)
      add :user_id, references(:users, on_delete: :restrict)

      add :inserted_at, :utc_datetime_usec, default: fragment("NOW()")
      add :updated_at, :utc_datetime_usec, default: fragment("NOW()")
    end

    create index(:tickets, :user_id)
    create index(:tickets, :event_id)
  end
end
