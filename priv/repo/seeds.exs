# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ticketed.Repo.insert!(%Ticketed.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Create stream to generate unique emails
users =
  Faker.Util.sample_uniq(20, fn -> Faker.Internet.email() end)
  |> Enum.map(fn email ->
    %{
      name: Faker.StarWars.character(),
      email: email
    }
  end)

Ticketed.Repo.insert_all(
  Ticketed.Users.User,
  users
)

Ticketed.Repo.insert_all(
  Ticketed.Events.Event,
  Enum.map(1..20, fn _ ->
    %{
      name: Faker.Cannabis.strain() <> " Fest",
      when: Faker.DateTime.forward(7),
      capacity: Faker.random_between(1, 1000)
    }
  end)
)
