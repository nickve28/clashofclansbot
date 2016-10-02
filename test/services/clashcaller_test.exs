defmodule ClashOfClansSlackbot.Services.ClashcallerTest do
  use ExUnit.Case

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

    #remove when bootup sync implemented
    ClashOfClansSlackbot.Adapters.Calendar.local_time
      |> :calendar.datetime_to_gregorian_seconds
      |> Kernel.+(300)
      |> :calendar.gregorian_seconds_to_datetime
      |> ClashOfClansSlackbot.Adapters.Calendar.set_time

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

  test "when calling reserve_attack it should return success" do
    mock_url = "http://clashcaller.com/war/1234"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    assert ClashOfClansSlackbot.Services.ClashCaller.reserve(1, "Nick")
  end

  test "when calling register attack it should return success" do
    mock_url = "http://clashcaller.com/war/1234"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    assert ClashOfClansSlackbot.Services.ClashCaller.attack(5, "Nick", 3) === {:ok, "<success>"}
  end
end



