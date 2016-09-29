defmodule MessageParserTest do
  use ExUnit.Case
  import Mock
  doctest MessageParser

  @mock_url "http://clashcaller.com/war/1234"
  @mock_reservation %Clashcaller.ClashcallerEntry{player: "nick", stars: "No attack", target: 3, position: 1}
  @mock_reservation_spaces %Clashcaller.ClashcallerEntry{player: "drew the trash bin", stars: "No attack", target: 3, position: 1}

  setup do
    mock_url = "http://clashcaller.com/war/1234"
    Storage.save_url(mock_url)
    {:ok, _} = ClashOfClansSlackbot.Services.ClashCaller.start_link
    :ok
  end

  test "parse_response should respond with no content if the message does not start with a valid command" do
    result = MessageParser.parse_response "start 10 man war"
    { :no_content, _ } = result
  end

  test "parse_war response should parse correct params back" do
    with_mock Clashcaller, [start_war: fn(_size, _name, _ename) ->
      { :ok, @mock_url }
    end] do

      input = "!startwar 10 \"Atomic Bullies \" \"The Trumps\""
      MessageParser.parse_response(input)
    end
  end

  test "should return a war url" do
    with_mock Clashcaller, [start_war: fn(_size, _name, _ename) ->  { :ok, @mock_url } end] do
      result = MessageParser.parse_response "!startwar 10 \"Atomic Bullies \" \"The Trumps\""
      assert result === { :ok, "I started the war, it can be found here: #{@mock_url}" }
    end
  end

  test "!war should return the latest war url" do
    Storage.save_url("foo")
    Storage.save_url(@mock_url)
    assert MessageParser.parse_response("!war url") === { :ok, "The current war url is #{@mock_url}" }
  end

  test "!reserve <target> <name> <warurl> should make a reservation for the player" do
    Storage.save_url @mock_url
    with_mock Clashcaller, [reserve_attack: fn (_name, _target, _warcode) ->
      { :ok, "<success>" }
    end] do
      input = "!reserve 1 Nick"
      assert (MessageParser.parse_response input) === { :ok, "<success>" }
    end
  end

  test "!reservations <empty> should not work" do
    { :no_content, _ } = MessageParser.parse_response("!reservations")
  end

  test "!reservations <target> should return reservations" do
    Storage.save_url @mock_url
    with_mock Clashcaller, [overview: fn (_warcode) ->
      { :ok, [@mock_reservation] }
    end] do
      assert MessageParser.parse_response("!reservations 3") === { :ok, "Reservation for nick with No attack" }
    end
  end

  test "!attack <target> <name> <stars> should fail if no reservation can be found" do
    Storage.save_url @mock_url
    with_mock Clashcaller, [overview: fn (_req) ->
      { :ok, [] }
    end] do
      assert MessageParser.parse_response("!attack 1 nick 3") === { :ok, "No reservation found for that player" }
    end
  end

  test "!attack <target> <name> <stars> should succeed if a reservation can be found" do
    Storage.save_url @mock_url
    with_mock Clashcaller, [overview: fn (_req) ->
      { :ok, [@mock_reservation] }
    end,
                            register_attack: fn (_warcode, _target, _pos, _stars) ->
      { :ok, "<success>" }
    end] do
      assert MessageParser.parse_response("!attack 3 nick 3") === { :ok, "<success>" }
    end
  end

  test "!attack <target> <name> <stars> should succeed even if the playername contains spaces" do
    Storage.save_url @mock_url
    with_mock Clashcaller, [overview: fn (_req) ->
      { :ok, [@mock_reservation_spaces] }
    end, register_attack: fn (_warcode, _target, _pos, _stars) ->
      { :ok, "<success>" }
    end] do
      assert MessageParser.parse_response("!attack 3 drew the trash bin 2") === {:ok, "<success>"}
    end
  end

  test "!overview <player> should return the reservations made by that player" do
    Storage.save_url @mock_url
    with_mock Clashcaller, [overview: fn (_req) ->
      { :ok, [@mock_reservation] }
    end] do

      expected = "Reservations made by nick:\nNo attack on base number 3"
      assert MessageParser.parse_response("!overview nick") === {:ok, expected}
    end
  end

  test "!overview <player> should return no known reservations if none known" do
    Storage.save_url @mock_url
    with_mock Clashcaller, [overview: fn (_req) ->
      { :ok, [] }
    end] do

      expected = "Player nick has no reservations."
      assert MessageParser.parse_response("!overview nick") === {:ok, expected}
    end
  end

end
