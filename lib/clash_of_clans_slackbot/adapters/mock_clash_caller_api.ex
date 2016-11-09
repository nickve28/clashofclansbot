defmodule ClashOfClansSlackbot.Adapters.MockClashCallerAPI do
  alias ClashOfClansSlackbot.Repositories.ClashCaller.ClashCallerEntry

  @behaviour ClashOfClansSlackbot.Behaviors.WarAPI
  @base_url "http://clashcaller.com/"

  @mock_clashcaller_reservations %HTTPotion.Response{body: "{\"general\":{\"type\":\"full_update\",\"maxcol\":2,\"checktime\":\"2016-05-11 10:14:10\",\"clanname\":\"Atomic Bullies\",\"enemyname\":\"L&#039;orchid\\u00e9e\",\"warcode\":\"1234\",\"size\":\"10\",\"starttime\":\"2016-05-10 15:15:20\",\"clanmessage\":\"It burns when I pee! - Griz\\n\",\"timerlength\":\"0\",\"updatetime\":\"2016-05-11 09:49:48\"},\"calls\":[{\"posy\":\"0\",\"posx\":\"0\",\"stars\":\"1\",\"playername\":\"Zoy\",\"calltime\":\"2016-05-09 15:19:31\",\"updatetime\":\"2016-05-09 15:42:30\",\"note\":null,\"last\":\"1\"},{\"posy\":\"3\",\"posx\":\"0\",\"stars\":\"5\",\"playername\":\"Austin\",\"calltime\":\"2016-05-09 15:58:07\",\"updatetime\":\"2016-05-10 14:44:19\",\"note\":null,\"last\":\"1\"},{\"posy\":\"4\",\"posx\":\"0\",\"stars\":\"5\",\"playername\":\"Nick\",\"calltime\":\"2016-05-09 17:28:28\",\"updatetime\":\"2016-05-10 14:44:14\",\"note\":null,\"last\":\"1\"},{\"posy\":\"1\",\"posx\":\"0\",\"stars\":\"1\",\"playername\":\"Zoy\",\"calltime\":\"2016-05-09 17:31:20\",\"updatetime\":\"2016-05-09 17:31:20\",\"note\":null,\"last\":\"1\"},{\"posy\":\"5\",\"posx\":\"0\",\"stars\":\"5\",\"playername\":\"Drew\",\"calltime\":\"2016-05-09 23:44:50\",\"updatetime\":\"2016-05-10 22:36:30\",\"note\":null,\"last\":\"1\"},{\"posy\":\"2\",\"posx\":\"0\",\"stars\":\"1\",\"playername\":\"GRIZ\",\"calltime\":\"2016-05-10 11:23:15\",\"updatetime\":\"2016-05-11 02:06:17\",\"note\":null,\"last\":\"0\"},{\"posy\":\"6\",\"posx\":\"0\",\"stars\":\"4\",\"playername\":\"Krill\",\"calltime\":\"2016-05-11 02:06:05\",\"updatetime\":\"2016-05-11 09:11:52\",\"note\":null,\"last\":\"0\"},{\"posy\":\"2\",\"posx\":\"1\",\"stars\":\"4\",\"playername\":\"Juke\",\"calltime\":\"2016-05-11 02:06:17\",\"updatetime\":\"2016-05-11 02:06:21\",\"note\":null,\"last\":\"1\"},{\"posy\":\"6\",\"posx\":\"1\",\"stars\":\"5\",\"playername\":\"Drew\",\"calltime\":\"2016-05-11 09:11:52\",\"updatetime\":\"2016-05-11 09:11:55\",\"note\":null,\"last\":\"1\"},{\"posy\":\"7\",\"posx\":\"0\",\"stars\":\"5\",\"playername\":\"Nick\",\"calltime\":\"2016-05-11 09:30:32\",\"updatetime\":\"2016-05-11 09:49:48\",\"note\":null,\"last\":\"1\"}],\"targets\":[],\"log\":[\"Monday, 3:19 pm : Zoy called target 1\",\"Monday, 3:21 pm : Nick called target 3\",\"Monday, 3:28 pm : deleted call by Nick on target 3\",\"Monday, 3:29 pm : Nick called target 4\",\"Monday, 3:32 pm : deleted call by Nick on target 4\",\"Monday, 3:33 pm : Nick called target 3\",\"Monday, 3:40 pm : Test called target 2\",\"Monday, 3:42 pm : deleted call by Test on target 2\",\"Monday, 3:42 pm : Test called target 1\",\"Monday, 3:42 pm : deleted call by Test on target 1\",\"Monday, 3:58 pm : Austin called target 4\",\"Monday, 4:02 pm : Nick attacked target 3 for 3 stars.\",\"Monday, 5:28 pm : deleted call by Nick on target 3\",\"Monday, 5:28 pm : Nick called target 5\",\"Monday, 5:31 pm : Zoy called target 2\",\"Monday, 11:44 pm : Drew called target 6\",\"Tuesday, 11:23 am : GRIZ called target 3\",\"Tuesday, 2:44 pm : Nick attacked target 5 for 3 stars.\",\"Tuesday, 2:44 pm : Austin attacked target 4 for 3 stars.\",\"Tuesday, 10:36 pm : Drew attacked target 6 for 3 stars.\",\"Tuesday, 10:36 pm : Drew called target 7\",\"Wednesday, 2:06 am : Krill called target 7\",\"Wednesday, 2:06 am : Krill attacked target 7 for 2 stars.\",\"Wednesday, 2:06 am : Juke called target 3\",\"Wednesday, 2:06 am : Juke attacked target 3 for 2 stars.\",\"Wednesday, 6:11 am : Juke called target 7\",\"Wednesday, 9:11 am : Drew attacked target 7 for 3 stars.\",\"Wednesday, 9:11 am : deleted call by Drew on target 7\",\"Wednesday, 9:11 am : deleted call by Juke on target 7\",\"Wednesday, 9:11 am : Drew called target 7\",\"Wednesday, 9:11 am : Drew attacked target 7 for 3 stars.\",\"Wednesday, 9:30 am : Nick called target 8\",\"Wednesday, 9:49 am : Nick attacked target 8 for 3 stars.\"]}",
 headers: %HTTPotion.Headers{hdrs: [connection: "close",
   "content-length": "3428", "content-type": "text/html",
   date: "Wed, 11 May 2016 14:14:10 GMT", server: "Apache/2.4.7 (Ubuntu)",
   vary: "Accept-Encoding", "x-powered-by": "PHP/5.5.9-1ubuntu4.4"]},
 status_code: 200}
  #todo parse

  def start_war(10, "error", ename) do
    {:err, %{code: 400}}
  end

  def start_war("Atomic Bullies", "The Trumps", 10) do
    {:ok, @base_url <> "war/newwar"}
  end

  def start_war(name, ename, size) do
    {:ok, @base_url <> "war/3tynq"}
  end

  def overview("empty") do
    {:ok, []}
  end

  def overview("12345") do
    res = @mock_clashcaller_reservations
      |> to_players
    {:ok, res}
  end

  def overview("2345") do
    {:ok, [
      %ClashCallerEntry{player: "Nick", position: 1, stars: "3 stars", target: 5}
    ]}
  end

  def overview("reservation_player_" <> name) do
    {:ok, [%ClashCallerEntry{player: name, position: 1, stars: "No attack", target: 1}]}
  end

  def overview("reservation_" <> target) do
    {:ok, [%ClashCallerEntry{player: "Nick", position: 1, stars: "No attack", target: String.to_integer(target)}]}
  end

  def overview("1234") do
    res = @mock_clashcaller_reservations
      |> to_players
    {:ok, res}
  end

  def overview(_), do: {:ok, []}

  defp to_players(response) do
    Poison.Parser.parse!(response.body)
      |> Map.get("calls")
      |> Enum.map(&(ClashCallerEntry.to_clashcaller_entry &1))
  end

  def reserve_attack(1, "Nick", "1234") do
    {:ok, "<success>"}
  end

  def reserve_attack(2, "Nick", "empty") do
    {:ok, "<success>"}
  end

  def reserve_attack(2, "Nick", "reservation_2") do
    {:ok, "<success>"}
  end

  def reserve_attack(2, "zoy", "reservation_2") do
    {:ok, "<success>"}
  end

  def reserve_attack(5, "zoy", "reservation_5") do
    {:ok, "<success>"}
  end

  def register_attack("1234", 5, 1, 3) do
    {:ok, "<success>"}
  end

  def register_attack(_, _, _, _), do: {:ok, "<success>"}

  def remove_reservation({_nr, _name, _warcode, 1}), do: {:ok, "<success>"}
  def remove_reservation({_nr, _name, _warcode, 2}), do: {:ok, "<success>"}

end
