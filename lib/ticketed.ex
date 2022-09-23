defmodule Ticketed do
  @moduledoc """
  Ticketed keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Ticketed.Repo
  alias Ticketed.{Events.Event, Tickets.Ticket, Users.User}

  import Ecto.Query

  @doc """
  Returns true if there is still capacity at the event.
  """
  def tickets_available?(%Event{id: event_id, capacity: event_capacity}) do
    ticket_count_query =
      from t in Ticket,
        where: t.event_id == ^event_id,
        select: count(t.id)

    tickets_sold = Repo.one!(ticket_count_query)

    event_capacity > tickets_sold
  end

  @doc """
  Creates a ticket
  """
  def create_ticket(user, event) do
    Ticketed.Tickets.create_ticket(%{
      user_id: user.id,
      event_id: event.id
    })
  end

  @doc """
  Sends confirmation email when ticket purchase confirmed.
  """
  def send_confirmation_email(user, event) do
    Ticketed.Mailer.send_confirmation(user, event)
  end

  @doc """
  Loads all users with a matching id 
  """
  def get_users_by_ids(user_ids) when is_list(user_ids) do
    Repo.all(
      from user in User,
        where: user.id in ^user_ids,
        select: {user.id, user}
    )
    |> Map.new()
  end

  @doc """
  Loads all events with a matching id 
  """
  def get_events_by_ids(event_ids) when is_list(event_ids) do
    Repo.all(
      from event in Event,
        where: event.id in ^event_ids,
        select: {event.id, event}
    )
    |> Map.new()
  end

  @doc """
  Inserts batch of tickets and returns them, if any fail the changeset 
  for the first failed item is returned.
  """
  @spec(
    insert_all_tickets(ticket_attrs :: list(map())) :: {:ok, list(%Ticket{})},
    {:error, Ecto.Changeset.t()}
  )
  def insert_all_tickets(tickets_attrs) do
    tickets_attrs
    |> Enum.with_index()
    |> List.foldl(Ecto.Multi.new(), fn
      {attrs, idx}, multi ->
        Ecto.Multi.insert(
          multi,
          {:ticket, idx},
          Ticketed.Tickets.Ticket.changeset(attrs)
        )
    end)
    |> Ticketed.Repo.transaction()
    |> case do
      {:ok, inserted_tickets} ->
        {:ok, Map.values(inserted_tickets)}

      {:error, _name, changeset, _} ->
        {:error, changeset}
    end
  end
end
