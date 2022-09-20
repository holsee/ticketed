defmodule Ticketed.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ticketed.Users` context.
  """

  @doc """
  Generate valid attrs
  """
  def valid_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      email: Faker.Internet.email(),
      name: Faker.Person.name()
    })
  end

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_attrs()
      |> Ticketed.Users.create_user()

    user
  end
end
