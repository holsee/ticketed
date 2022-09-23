defmodule Ticketed.TicketedTest do
  use Ticketed.DataCase

  import Ticketed.{UsersFixtures, EventsFixtures, TicketsFixtures}

  alias Ticketed.Tickets.Ticket

  describe "tickets_available?" do
    test "should return true if there are tickets available" do
      event = event_fixture()
      assert true == Ticketed.tickets_available?(event)
    end

    test "should return false if there are no tickets available" do
      event = event_fixture(capacity: 10)
      _tickets = 1..10 |> Enum.map(fn _ -> ticket_fixture(event_id: event.id) end)
      assert false == Ticketed.tickets_available?(event)
    end
  end

  describe "create_ticket" do
    test "should create ad ticket record" do
      %_{id: user_id} = user = user_fixture()
      %_{id: event_id} = event = event_fixture()

      assert {:ok, %Ticket{user_id: ^user_id, event_id: ^event_id}} =
               Ticketed.create_ticket(user, event)
    end
  end

  describe "get_users_by_ids" do
    test "should load users with match id" do
      user = user_fixture()
      assert %{user.id => user} == Ticketed.get_users_by_ids([user.id])
    end
  end

  describe "get_events_by_ids" do
    test "should load events with match id" do
      event = event_fixture()
      assert %{event.id => event} == Ticketed.get_events_by_ids([event.id])
    end
  end

  describe "send_confirmation_email" do
    import Swoosh.TestAssertions
    import Swoosh.Email

    test "should send email" do
      user = user_fixture()
      event = event_fixture()
      Ticketed.send_confirmation_email(user, event)

      expected_email =
        new()
        |> to({user.name, user.email})
        |> from({"Ticketed", "noreply@ticketed.com"})
        |> subject("Your #{event.name} Ticket!")
        |> html_body("""
          <h1>Hello #{user.name}</h1>
          <p>Your order has been confirmed for #{event.name}!</p> 
        """)

      assert_email_sent(expected_email)
    end
  end

  describe "insert_all_tickets" do
    test "should insert all tickets" do
      ticket_attrs = Enum.map(0..3, fn _ -> Ticketed.TicketsFixtures.valid_attrs() end)
      assert {:ok, [%Ticket{} | _] = tickets} = Ticketed.insert_all_tickets(ticket_attrs)
      assert length(ticket_attrs) == length(tickets)
    end

    test "should return error changeset when a single item in the batch is invalid" do
      ticket_attrs = [
        Ticketed.TicketsFixtures.valid_attrs(),
        Ticketed.TicketsFixtures.valid_attrs() |> Map.delete(:event_id)
      ]

      assert {:error, %Ecto.Changeset{}} = Ticketed.insert_all_tickets(ticket_attrs)
    end
  end
end
