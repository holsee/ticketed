defmodule Ticketed.TicketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ticketed.Tickets` context.
  """

  @doc """
  Generates valid attrs
  """
  def valid_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      event_id: Ticketed.EventsFixtures.event_fixture().id,
      user_id: Ticketed.UsersFixtures.user_fixture().id
    })
  end

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    {:ok, ticket} =
      attrs
      |> valid_attrs()
      |> Ticketed.Tickets.create_ticket()

    ticket
  end
end
