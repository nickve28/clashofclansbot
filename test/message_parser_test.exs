defmodule MessageParserTest do
  use ExUnit.Case
  import Mock
  doctest MessageParser

  @mock_url "http://clashcaller.com/war/1234"

  test "parse_response should respond with no content if the message does not start with a valid command" do
    result = MessageParser.parse_response "start 10 man war"
    { :no_content, _ } = result
  end

  test "parse_war response should parse correct params back" do
    with_mock Clashcaller, [start_war: fn(req) ->
      assert String.match?(req, ~r/Atomic Bullies/)
      assert String.match?(req, ~r/10/)
      assert String.match?(req, ~r/The Trumps/)
      { :ok, @mock_url }
    end] do

      input = "!startwar 10 \"Atomic Bullies \" \"The Trumps\""
      MessageParser.parse_response(input)
    end
  end

  test "should return a war url" do
    with_mock Clashcaller, [start_war: fn(req) ->  { :ok, @mock_url } end] do
      result = MessageParser.parse_response "!startwar 10 \"Atomic Bullies \" \"The Trumps\""
      assert result === { :ok, "I started the war, it can be found here: #{@mock_url}" }
    end
  end

  test "!war should return the latest war url" do
    test_db = Application.get_env :clash_of_clans_slackbot, :database
    Storage.save_url("foo")
    Storage.save_url(@mock_url)
    assert MessageParser.parse_response("!war url") === "The current war url is #{@mock_url}"
  end
end
