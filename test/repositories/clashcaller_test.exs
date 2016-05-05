defmodule Clashcaller.RequestTest do
  use ExUnit.Case
  doctest Clashcaller.Request

  import Mock

  @mock_clashcaller  %HTTPotion.Response{body: "war/3tynq",
      headers: %HTTPotion.Headers{hdrs: [connection: "close", "content-length": "9",
        "content-type": "text/html", date: "Wed, 04 May 2016 19:10:57 GMT",
        server: "Apache/2.4.7 (Ubuntu)", "x-powered-by": "PHP/5.5.9-1ubuntu4.4"]},
      status_code: 200}
  @mock_clashcaller_baseurl "http://clashcaller.com/"

  test "construct should make a named list" do
    {clan_name, enemy_name, size} = {"foo", "bar", 10}
    expected = { :ok, [REQUEST: "CREATE_WAR", cname: "foo", ename: "bar", size: "10", timers: "0", searchable: "false"] }
    assert Clashcaller.Request.construct(clan_name, enemy_name, size) === expected
  end

  test "construct doesnt match a non integer size" do
    {clan_name, enemy_name, size} = {"foo", "bar", "10"}
    assert_raise FunctionClauseError, fn -> Clashcaller.Request.construct(clan_name, enemy_name, size) end
  end

  test "construct fails if a wrong size is given" do
    {clan_name, enemy_name, size} = {"foo", "bar", 5}
    { :err, _ } = Clashcaller.Request.construct(clan_name, enemy_name, size)
  end

  test "transform to request params" do
    params = [REQUEST: "CREATE_WAR", cname: "foo", ename: "bar", size: "10", timers: "0", searchable: "false"]
    expected = Enum.join ["REQUEST=CREATE_WAR", "cname=foo", "ename=bar", "size=10", "timers=0",
                "searchable=false"], "&"
    assert Clashcaller.Request.to_form_body(params) === expected

  end

  test "start war" do
    with_mock HTTPotion, [post: fn(_url, _headers) -> @mock_clashcaller end] do
      params = Enum.join ["REQUEST=CREATE_WAR", "cname=foo", "ename=bar", "size=10", "timers=0",
                  "searchable=false"], "&"
      assert Clashcaller.start_war(params) === { :ok, @mock_clashcaller_baseurl <> @mock_clashcaller.body }
    end
  end
end
