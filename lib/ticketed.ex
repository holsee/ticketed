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

  # def insert_all_tickets(messages) do
  #   # Normally `Repo.insert_all/3` if using `Ecto`...
  #   Process.sleep(Enum.count(messages) * 250)
  #   messages
  # end
end
