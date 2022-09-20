defmodule Ticketed.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :when, :utc_datetime_usec
      add :capacity, :integer, default: 1

      add :inserted_at, :utc_datetime_usec, default: fragment("NOW()")
      add :updated_at, :utc_datetime_usec, default: fragment("NOW()")
    end
  end
end
