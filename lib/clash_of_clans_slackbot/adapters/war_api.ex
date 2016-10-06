defmodule ClashOfClansSlackbot.Behaviors.WarAPI do
  @callback start_war(Integer.t, String.t, String.t) :: Tuple.t
  @callback overview(String.t) :: [%Clashcaller.ClashcallerEntry{}]
  @callback reserve_attack(Integer.t String.t, String.t) :: String.t
  @callback register_attack(String.t, Integer.t, Integer.t, Integer.t) :: String.t
end
