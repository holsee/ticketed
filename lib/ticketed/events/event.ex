defmodule Ticketed.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  schema "events" do
    field :name, :string
    field :when, :utc_datetime_usec
    field :capacity, :integer, default: 1

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:capacity, :name, :when])
    |> validate_required([:capacity, :name, :when])
    |> validate_number(:capacity, greater_than_or_equal_to: 1)
  end
end
