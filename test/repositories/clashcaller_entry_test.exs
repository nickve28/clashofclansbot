defmodule ClashOfClansSlackbot.Repositories.ClashCaller.ClashCallerEntryTest do
  alias ClashOfClansSlackbot.Repositories.ClashCaller.ClashCallerEntry
  use ExUnit.Case
  doctest ClashCallerEntry

  @example  %{"calltime" => "2016-05-11 09:30:32", "last" => "1", "note" => nil,
   "playername" => "Nick", "posx" => "0", "posy" => "7", "stars" => "5",
   "updatetime" => "2016-05-11 09:49:48"}

 test "map to Clashcaller Entry" do
   assert ClashCallerEntry.to_clashcaller_entry(@example) === %ClashCallerEntry{ player: "Nick", target: 8, stars: "3 stars", "position": 1}
 end

end

