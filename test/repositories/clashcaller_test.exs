defmodule Clashcaller.RequestTest do
  use ExUnit.Case
  doctest Clashcaller.Request

  test "construct should make a named list" do
    {clan_name, enemy_name, size} = {"foo", "bar", 10}
    expected = [REQUEST: "CREATE_WAR", cname: "foo", ename: "bar", size: "10", timers: "0", searchable: "false"]
    assert Clashcaller.Request.construct(clan_name, enemy_name, size) === expected
  end

  test "transform to request params" do
    params = [REQUEST: "CREATE_WAR", cname: "foo", ename: "bar", size: "10", timers: "0", searchable: "false"]
    expected = Enum.join ["REQUEST=CREATE_WAR", "cname=foo", "ename=bar", "size=10", "timers=0",
                "searchable=false"], "&"
    assert Clashcaller.Request.to_form_body(params) === expected

  end
end
