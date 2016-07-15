defmodule ClashOfClansSlackbot.Services.ClashApiTest do
  use ExUnit.Case
  import Mock

  setup do
    {:ok, players: %HTTPotion.Response{body: "{\"items\":[{\"tag\":\"#UGV82QR8\",\"name\":\"Zoyvod\",\"role\":\"coLeader\",\"expLevel\":99,\"league\":{\"id\":29000000,\"name\":\"Unranked\",\"iconUrls\":{\"small\":\"https://api-assets.clashofclans.com/leagues/72/e--YMyIexEQQhE4imLoJcwhYn6Uy8KqlgyY3_kFV6t4.png\",\"tiny\":\"https://api-assets.clashofclans.com/leagues/36/e--YMyIexEQQhE4imLoJcwhYn6Uy8KqlgyY3_kFV6t4.png\"}},\"trophies\":2222,\"clanRank\":2,\"previousClanRank\":2,\"donations\":40,\"donationsReceived\":120},{\"tag\":\"#2JQL0822\",\"name\":\"[C]rAnCkEt~\",\"role\":\"admin\",\"expLevel\":141,\"league\":{\"id\":29000011,\"name\":\"Crystal League II\",\"iconUrls\":{\"small\":\"https://api-assets.clashofclans.com/leagues/72/jhP36EhAA9n1ADafdQtCP-ztEAQjoRpY7cT8sU7SW8A.png\",\"tiny\":\"https://api-assets.clashofclans.com/leagues/36/jhP36EhAA9n1ADafdQtCP-ztEAQjoRpY7cT8sU7SW8A.png\",\"medium\":\"https://api-assets.clashofclans.com/leagues/288/jhP36EhAA9n1ADafdQtCP-ztEAQjoRpY7cT8sU7SW8A.png\"}},\"trophies\":2178,\"clanRank\":4,\"previousClanRank\":4,\"donations\":0,\"donationsReceived\":0},{\"tag\":\"#8CJCGV9L\",\"name\":\"Nick\",\"role\":\"coLeader\",\"expLevel\":141,\"league\":{\"id\":29000009,\"name\":\"Gold League I\",\"iconUrls\":{\"small\":\"https://api-assets.clashofclans.com/leagues/72/CorhMY9ZmQvqXTZ4VYVuUgPNGSHsO0cEXEL5WYRmB2Y.png\",\"tiny\":\"https://api-assets.clashofclans.com/leagues/36/CorhMY9ZmQvqXTZ4VYVuUgPNGSHsO0cEXEL5WYRmB2Y.png\",\"medium\":\"https://api-assets.clashofclans.com/leagues/288/CorhMY9ZmQvqXTZ4VYVuUgPNGSHsO0cEXEL5WYRmB2Y.png\"}},\"trophies\":1856,\"clanRank\":10,\"previousClanRank\":7,\"donations\":469,\"donationsReceived\":452}],\"paging\":{\"cursors\":{}}}",
  headers: %HTTPotion.Headers{hdrs: ["cache-control": "public max-age=600",
     connection: "keep-alive", "content-length": "11806",
      "content-type": "application/json; charset=utf-8",
       date: "Thu, 14 Jul 2016 19:32:52 GMT",
        "strict-transport-security": "max-age=43200",
         via: "1.1 e50082f108f86da8af6ed222cfcad2b5.cloudfront.net (CloudFront)",
          "x-amz-cf-id": "0vQqnUmT4hyXg5gVpfa2LdUl3I0vlHWI48GA53QjgciXVB3d_1nJzw==",
           "x-cache": "Miss from cloudfront", "x-content-type-options": "nosniff"]},
      status_code: 200}}
  end

  test "putting data in the agent should save the players which can be returned by listing", shared do
    expected = [
      %ClashOfClansSlackbot.Models.Player{name: "Zoyvod", donations: 40, donations_received: 120},
      %ClashOfClansSlackbot.Models.Player{name: "[C]rAnCkEt~", donations: 0, donations_received: 0},
      %ClashOfClansSlackbot.Models.Player{name: "Nick", donations: 469, donations_received: 452}
    ]

    with_mock HTTPotion, [get: fn(_url, _headers) -> shared[:players] end] do
      ClashOfClansSlackbot.Services.ClashApi.start_link("#C8000C0", "sometoken")
      ClashOfClansSlackbot.Services.ClashApi.poll
      assert ClashOfClansSlackbot.Services.ClashApi.list() === expected
    end
  end

  test "list_bad_donators should return all bad donators", shared do
    expected= [
      %ClashOfClansSlackbot.Models.Player{name: "[C]rAnCkEt~", donations: 0, donations_received: 0}
    ]

    with_mock HTTPotion, [get: fn(_url, _headers) -> shared[:players] end] do
      ClashOfClansSlackbot.Services.ClashApi.start_link("#C8000C0", "sometoken")
      ClashOfClansSlackbot.Services.ClashApi.poll
      assert ClashOfClansSlackbot.Services.ClashApi.list_bad_donators === expected
    end
  end
end
