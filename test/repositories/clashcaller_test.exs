defmodule ClashOfClansSlackbot.Repositories.ClashCaller.RequestTest do
  alias ClashOfClansSlackbot.Repositories.ClashCaller.Request
  use ExUnit.Case
  doctest Request

  test "construct should make a named list" do
    {clan_name, enemy_name, size} = {"foo", "bar", 10}
    expected = { :ok, [REQUEST: "CREATE_WAR", cname: "foo", ename: "bar", size: "10", timers: "0", searchable: "false"] }
    assert Request.construct(clan_name, enemy_name, size) === expected
  end

  test "construct doesnt match a non integer size" do
    {clan_name, enemy_name, size} = {"foo", "bar", "10"}
    assert_raise FunctionClauseError, fn -> Request.construct(clan_name, enemy_name, size) end
  end

  test "construct fails if a wrong size is given" do
    {clan_name, enemy_name, size} = {"foo", "bar", 5}
    { :err, _ } = Request.construct(clan_name, enemy_name, size)
  end

  test "construct reserve attack" do
    {target, name, war} = {1, "nick", "1234"}
    {:ok, result} = Request.construct(target, name, war)
    assert result === [REQUEST: "APPEND_CALL", warcode: "1234", "posy": "0", value: "nick"]
  end

  test "construct reservations list" do
    assert Request.construct("1234") === { :ok ,[REQUEST: "GET_FULL_UPDATE", warcode: "1234"] }
  end

  test "transform to request params" do
    params = [REQUEST: "CREATE_WAR", cname: "foo", ename: "bar", size: "10", timers: "0", searchable: "false"]
    expected = Enum.join ["REQUEST=CREATE_WAR", "cname=foo", "ename=bar", "size=10", "timers=0",
                "searchable=false"], "&"
    assert Request.to_form_body(params) === expected
  end

  test "construct delete_attack" do
    expected = {:ok, [REQUEST: "DELETE_CALL", warcode: "1234", posy: "0", value: "Nick", posx: "0"]}
    assert Request.construct({1, "Nick", "1234", 1}, "DELETE") === expected
  end
end
