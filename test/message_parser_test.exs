defmodule MessageParserTest do
  use ExUnit.Case
  import Mock
  doctest MessageParser

  test "parse_response should respond with no content if the message does not start with a valid command" do
    result = MessageParser.parse_response "start 10 man war"
    { :no_content, _ } = result
  end

  test "parse_war response should parse correct params back" do
    with_mock Clashcaller, [start_war: fn(req) -> 
      assert String.match?(req, ~r/Atomic Bullies/)
      assert String.match?(req, ~r/10/)
      assert String.match?(req, ~r/The Trumps/)
    end] do

      input = "!startwar 10 \"Atomic Bullies \" \"The Trumps\""
      MessageParser.parse_response(input)
    end
  end
end
