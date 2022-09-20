defmodule Ticketed.EventsTest do
  use Ticketed.DataCase

  alias Ticketed.Events

  describe "events" do
    alias Ticketed.Events.Event

    import Ticketed.EventsFixtures

    @invalid_attrs %{name: nil, when: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = valid_attrs()

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.name == valid_attrs.name
      assert event.when == valid_attrs.when
      assert event.capacity == valid_attrs.capacity
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = valid_attrs()

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.name == update_attrs.name
      assert event.when == update_attrs.when
      assert event.capacity == update_attrs.capacity
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
