defmodule ClashOfClansSlackbot.Services.ClashcallerTest do
  use ExUnit.Case

  test "when starting the service it should sync at startup" do
    mock_url = "http://clashcaller.com/war/2345"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

     expected = [
      %Clashcaller.ClashcallerEntry{player: "Nick", position: 1, stars: "3 stars", target: 5}
    ]

    {_, reservations, _} = :sys.get_state(ClashOfClansSlackbot.Services.ClashCaller)

    assert reservations === expected
  end

  test "when calling overview it should put the war state in the correct format" do
    mock_url = "http://clashcaller.com/war/empty"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    time = ClashOfClansSlackbot.Adapters.Calendar.local_time

    updated_time = time
      |> :calendar.datetime_to_gregorian_seconds
      |> Kernel.+(300)
      |> :calendar.gregorian_seconds_to_datetime
      |> ClashOfClansSlackbot.Adapters.Calendar.set_time

    result = ClashOfClansSlackbot.Services.ClashCaller.overview


    expected = {mock_url, [], updated_time}

    assert :sys.get_state(ClashOfClansSlackbot.Services.ClashCaller) === expected
  end

  test "when calling overview and the last_sync is less than 5 minutes, it should not refresh the state" do
    mock_url = "http://clashcaller.com/war/empty"
    Storage.save_url(mock_url)

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    state = :sys.get_state(ClashOfClansSlackbot.Services.ClashCaller)
    {_, reservations, current_time} = state
    assert reservations === []

    #refer to other url with new entries
    new_url = "http://clashcaller.com/war/1234"
    new_state = {new_url, reservations, current_time}
    :sys.replace_state(ClashOfClansSlackbot.Services.ClashCaller, fn (_) -> new_state end)

    ClashOfClansSlackbot.Services.ClashCaller.overview
    {_, new_reservations, _} = :sys.get_state(ClashOfClansSlackbot.Services.ClashCaller)
    assert new_reservations === []
  end

  test "when calling overview and the last_sync is 5 minutes or more, it should refresh the state" do
    mock_url = "http://clashcaller.com/war/empty"
    Storage.save_url(mock_url)

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    state = :sys.get_state(ClashOfClansSlackbot.Services.ClashCaller)
    {_, reservations, current_time} = state
    current_time
      |> :calendar.datetime_to_gregorian_seconds
      |> Kernel.+(300)
      |> :calendar.gregorian_seconds_to_datetime
      |> ClashOfClansSlackbot.Adapters.Calendar.set_time

    assert reservations === []

    #refer to other url with new entries
    {:ok, expected} = ClashOfClansSlackbot.Adapters.MockClashCallerAPI.overview("1234")

    new_url = "http://clashcaller.com/war/1234"
    new_state = {new_url, reservations, current_time}
    :sys.replace_state(ClashOfClansSlackbot.Services.ClashCaller, fn (_) -> new_state end)


    ClashOfClansSlackbot.Services.ClashCaller.overview
    {_, new_reservations, _} = :sys.get_state(ClashOfClansSlackbot.Services.ClashCaller)
    assert new_reservations === expected
  end

  test "when calling overview it should output the war overview, sorted and showing the best results per target" do
    mock_url = "http://clashcaller.com/war/1234"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = [
      %Clashcaller.ClashcallerEntry{player: "Zoy", position: 1, stars: "No attack", target: 1},
      %Clashcaller.ClashcallerEntry{player: "Zoy", position: 1, stars: "No attack", target: 2},
      %Clashcaller.ClashcallerEntry{player: "Juke", position: 2, stars: "2 stars", target: 3},
      %Clashcaller.ClashcallerEntry{player: "Austin", position: 1, stars: "3 stars", target: 4},
      %Clashcaller.ClashcallerEntry{player: "Nick", position: 1, stars: "3 stars", target: 5},
      %Clashcaller.ClashcallerEntry{player: "Drew", position: 1, stars: "3 stars", target: 6},
      %Clashcaller.ClashcallerEntry{player: "Drew", position: 2, stars: "3 stars", target: 7},
      %Clashcaller.ClashcallerEntry{player: "Nick", position: 1, stars: "3 stars", target: 8}
    ]

   result = ClashOfClansSlackbot.Services.ClashCaller.overview
    assert result === {:ok, expected}
  end

  test "when calling overview but no registrations have yet been made it should return an empty list" do
    mock_url = "http://clashcaller.com/war/empty"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    result = ClashOfClansSlackbot.Services.ClashCaller.overview
    assert result === {:ok, []}
  end

  test "when calling player overview but player has no registrations it should return an empty list" do
    mock_url = "http://clashcaller.com/war/empty"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    result = ClashOfClansSlackbot.Services.ClashCaller.player_overview("Jukie")
    assert result === {:ok, []}
  end

  test "when calling player overview it should return the player reservations" do
    mock_url = "http://clashcaller.com/war/1234"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = [
      %Clashcaller.ClashcallerEntry{player: "Nick", position: 1, stars: "3 stars", target: 5},
      %Clashcaller.ClashcallerEntry{player: "Nick", position: 1, stars: "3 stars", target: 8}
    ]
    result = ClashOfClansSlackbot.Services.ClashCaller.player_overview("Nick")
    assert result === {:ok, expected}
  end

  test "when calling reserve_attack it should return the reservation" do
    mock_url = "http://clashcaller.com/war/empty"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = %Clashcaller.ClashcallerEntry{player: "Nick", position: 1, stars: "No attack", target: 2}

    assert ClashOfClansSlackbot.Services.ClashCaller.reserve(2, "Nick") === {:ok, expected}
  end

  test "when calling reserve_attack on a target with a reservation it should assume the next position" do
    mock_url = "http://clashcaller.com/war/reservation_2"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = %Clashcaller.ClashcallerEntry{player: "zoy", position: 2, stars: "No attack", target: 2}

    assert ClashOfClansSlackbot.Services.ClashCaller.reserve(2, "zoy") === {:ok, expected}
  end

  test "when calling reserve_attack on a target that the player already reserved, it should return an error" do
    mock_url = "http://clashcaller.com/war/reservation_2"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = {:error, :ereservationexists}
    assert ClashOfClansSlackbot.Services.ClashCaller.reserve(2, "Nick") === expected
  end

  test "when calling reserve_attack on a target that the player already reserved, it should return an error, regardless of name having trailing spaces" do
    mock_url = "http://clashcaller.com/war/reservation_2"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = {:error, :ereservationexists}
    assert ClashOfClansSlackbot.Services.ClashCaller.reserve(2, "Nick ") === expected
  end

  test "when calling register attack it should return the updated entry" do
    mock_url = "http://clashcaller.com/war/1234"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = %Clashcaller.ClashcallerEntry{player: "Nick", position: 1, stars: "3 stars", target: 5}
    assert ClashOfClansSlackbot.Services.ClashCaller.attack(5, "Nick", 3) === {:ok, expected}
  end

  test "when calling register attack but there is no reservation it should return an error" do
    mock_url = "http://clashcaller.com/war/empty"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = {:error, :enoreservation}
    assert ClashOfClansSlackbot.Services.ClashCaller.attack(5, "Nick", 3) === expected
  end

  test "when calling create war it should return the war url" do
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = {:ok, "http://clashcaller.com/war/newwar"}
    assert ClashOfClansSlackbot.Services.ClashCaller.create_war("Atomic Bullies", "The Trumps", 10) === expected
  end


  test "when calling create war it should the time to current time " do
    time = ClashOfClansSlackbot.Adapters.Calendar.local_time

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    ClashOfClansSlackbot.Services.ClashCaller.create_war("Atomic Bullies", "The Trumps", 10)

    {_, _, sync_time} = :sys.get_state(ClashOfClansSlackbot.Services.ClashCaller)
    assert sync_time === time
  end

  test "when calling remove_reservation it should give an error if the reservation can not be found" do
    mock_url = "http://clashcaller.com/war/empty"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = {:error, :enoreservation}

    assert ClashOfClansSlackbot.Services.ClashCaller.remove_reservation(5, "Nick") === expected
  end

  test "when calling remove_reservation it should remove the reservation" do
    mock_url = "http://clashcaller.com/war/reservation_5"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    reservation = %Clashcaller.ClashcallerEntry{player: "Nick", position: 1, stars: "No attack", target: 5}
    expected = {:ok, reservation}

    assert ClashOfClansSlackbot.Services.ClashCaller.remove_reservation(5, "Nick") === expected
  end

  test "when calling remove_reservation while two reservations exist it should remove the matching reservation only" do
    mock_url = "http://clashcaller.com/war/reservation_5"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    ClashOfClansSlackbot.Services.ClashCaller.reserve(5, "zoy")
    expected = [
      %Clashcaller.ClashcallerEntry{player: "Nick", target: 5, position: 1, stars: "No attack"}
    ]

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.remove_reservation(5, "zoy")
    {:ok, reservations} = ClashOfClansSlackbot.Services.ClashCaller.reservations(5)
    assert reservations === expected
  end
end



