defmodule Ticketed.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string

      add :inserted_at, :utc_datetime_usec, default: fragment("NOW()")
      add :updated_at, :utc_datetime_usec, default: fragment("NOW()")
    end
  end
end
