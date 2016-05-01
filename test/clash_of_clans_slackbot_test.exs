defmodule ClashOfClansSlackbotTest do
  use ExUnit.Case
  doctest ClashOfClansSlackbot

  import Mock

  test "token not present" do
    result = ClashOfClansSlackbot.authenticate(nil)
    expected = { :err, "No token provided" }
    assert result == expected
  end

  test "authenticate succesfull" do
    with_mock SlackClient, [start: fn(_token) -> {:ok, true} end] do
      result = ClashOfClansSlackbot.authenticate("foo")
      assert called SlackClient.start("foo")
    end
  end
end
