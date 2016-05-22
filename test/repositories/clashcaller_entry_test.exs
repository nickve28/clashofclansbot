defmodule Clashcaller.ClashcallerEntryTest do
  use ExUnit.Case
  doctest Clashcaller.ClashcallerEntry

  @example  %{"calltime" => "2016-05-11 09:30:32", "last" => "1", "note" => nil,
   "playername" => "Nick", "posx" => "0", "posy" => "7", "stars" => "5",
   "updatetime" => "2016-05-11 09:49:48"}

 test "map to Clashcaller Entry" do
   assert Clashcaller.ClashcallerEntry.to_clashcaller_entry(@example) === %Clashcaller.ClashcallerEntry{ player: "Nick", target: 8, stars: "3 stars", "position": 1}
 end

end

