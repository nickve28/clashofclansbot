defmodule ClashOfClansSlackbotTest do
  use ExUnit.Case
  doctest ClashOfClansSlackbot

  test "token not present" do
    result = ClashOfClansSlackbot.authenticate(nil)
    expected = { :err, "No token provided" }
    assert result == expected
  end
end
