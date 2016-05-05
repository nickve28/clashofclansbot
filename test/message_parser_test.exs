defmodule MessageParserTest do
  use ExUnit.Case
  doctest MessageParser

  test "parse_response should respond with no content if the message does not start with a !" do
    result = MessageParser.parse_response "start 10 man war"
    { :no_content, _ } = result
  end

  test "parse response should respond ok if message starts with a !" do
    result = MessageParser.parse_response "!start 10 man war"
    { :ok, _ } = result
  end
end
