defmodule Ticketed.Tickets.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  schema "tickets" do
    belongs_to :event, Ticketed.Events.Event
    belongs_to :user, Ticketed.Users.User

    timestamps()
  end

  @doc false
  def changeset(ticket \\ %__MODULE__{}, attrs) do
    ticket
    |> cast(attrs, [:user_id, :event_id])
    |> validate_required([:user_id, :event_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:event_id)
  end
end
