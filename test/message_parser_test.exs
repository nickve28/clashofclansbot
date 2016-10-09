defmodule MessageParserTest do
  use ExUnit.Case
  doctest MessageParser

  test "parse_response should respond with no content if the message does not start with a valid command" do
    result = MessageParser.parse_response "start 10 man war"
    { :no_content, _ } = result
  end

  test "!startwar <size> <name> <ename> should return a war url" do
    Storage.save_url("http://clashcaller.com/war/empty")
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    result = MessageParser.parse_response "!startwar 10 \"Atomic Bullies \" \"The Trumps\""
    expected = "newwar"

    assert result === { :ok, "I started the war, it can be found here: http://clashcaller.com/war/newwar"}
  end

  test "calling !overview after !war should yield no reservations" do
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    MessageParser.parse_response "!startwar 10 \"Init\" \"State\""
    result = MessageParser.parse_response("!overview")
    {:ok, _} = result
  end

  test "!war should return the latest war url" do
    Storage.save_url("http://clashcaller.com/war/1234")
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    assert MessageParser.parse_response("!war url") === { :ok, "The current war url is http://clashcaller.com/war/1234" }
  end

  test "!reserve <target> <name> <warurl> should make a reservation for the player" do
    Storage.save_url "http://clashcaller.com/war/1234"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    expected = {:ok, "Reservation for Nick has been made on #1"}
    input = "!reserve 1 Nick"
    assert MessageParser.parse_response(input) === expected
  end

  test "!reserve <target> should work even if the name has appended whitespaces" do
    Storage.save_url "http://clashcaller.com/war/1234"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    expected = {:ok, "Reservation for Nick has been made on #1"}
    input = "!reserve 1 Nick  "
    assert MessageParser.parse_response(input) === expected
  end

  test "!reserve <target> should give a response if a reservation already exists" do
    Storage.save_url "http://clashcaller.com/war/reservation_1"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    expected = {:ok, "Player Nick already has a reservation for #1."}
    input = "!reserve 1 Nick"
    assert MessageParser.parse_response(input) === expected
  end

  test "!reserve <target> should give a response if a reservation already exists, trailing whitespace ignored" do
    Storage.save_url "http://clashcaller.com/war/reservation_1"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    expected = {:ok, "Player Nick already has a reservation for #1."}
    input = "!reserve 1 Nick  "
    assert MessageParser.parse_response(input) === expected
  end


  test "!reservations <empty> should not work" do
    { :no_content, _ } = MessageParser.parse_response("!reservations")
  end

  test "!reservations <target> should return reservations" do
    Storage.save_url "http://clashcaller.com/war/reservation_3"
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    assert MessageParser.parse_response("!reservations 3") === { :ok, "Reservation for Nick with No attack" }
  end

  test "!attack <target> <name> <stars> should fail if no reservation can be found" do
    Storage.save_url "http://clashcaller.com/war/reservation_3"
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    assert MessageParser.parse_response("!attack 1 nick 3") === { :ok, "No reservation found for that player" }
  end

  test "!attack <target> <name> <stars> should succeed if a reservation can be found" do
    Storage.save_url "http://clashcaller.com/war/reservation_3"
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    assert MessageParser.parse_response("!attack 3 Nick 3") === { :ok, "Nick attacked #3 with score: 3 stars!" }
  end

  test "!attack <target> <name> <stars> should succeed if a reservation can be found - even double digit" do
    Storage.save_url "http://clashcaller.com/war/reservation_14"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    assert MessageParser.parse_response("!attack 14 Nick 3") === { :ok, "Nick attacked #14 with score: 3 stars!" }
  end

  test "!attack <target> <name> <stars> should succeed even if the playername contains spaces" do
    Storage.save_url "http://clashcaller.com/war/reservation_player_drew the trash bin"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    assert MessageParser.parse_response("!attack 1 drew the trash bin  2") === {:ok, "drew the trash bin attacked #1 with score: 2 stars!"}
  end

  test "!overview <player> should return the reservations made by that player" do
    Storage.save_url "http://clashcaller.com/war/reservation_player_nick"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link

    expected = "Reservations made by nick:\nNo attack on base number 1"
    assert MessageParser.parse_response("!overview nick") === {:ok, expected}
  end

  test "!overview <player> should return no known reservations if none known" do
    Storage.save_url "http://clashcaller.com/war/reservation_player_zoy"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    expected = "Player nick has no reservations."
    assert MessageParser.parse_response("!overview nick") === {:ok, expected}
  end

  test "!help should give an overview of commands" do
    commands = [
      "!startwar", "!reservations", "!overview", "!reserve", "!attack", "!war", "!unreserve"
    ]
    {:ok, result} = MessageParser.parse_response("!help")

    Enum.each(commands, fn command ->
      {_, _} = :binary.match(result, command)
    end)
  end

  test "when calling !unreserve <target> <name> it should remove the returned reservation" do
    Storage.save_url "http://clashcaller.com/war/reservation_player_zoy"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    expected = "Successfully removed the reservation on #1 for player zoy."
    assert MessageParser.parse_response("!unreserve 1 zoy") === {:ok, expected}
  end

  test "when calling !unreserve <target> <name> it should give an error if it can not find the reservation" do
    Storage.save_url "http://clashcaller.com/war/empty"

    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    expected = "Player zoy has no reservation registered on #1."
    assert MessageParser.parse_response("!unreserve 1 zoy") === {:ok, expected}
  end

end
