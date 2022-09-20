defmodule Ticketed.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ticketed.Events` context.
  """

  @doc """
  Generates valid attrs
  """
  def valid_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: Faker.Cannabis.strain() <> " Fest",
      when: Faker.DateTime.forward(7),
      capacity: Faker.random_between(1, 10_000)
    })
  end

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> valid_attrs()
      |> Ticketed.Events.create_event()

    event
  end
end
