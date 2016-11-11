defmodule ClashOfClansSlackbot.Behaviors.WarAPI do
  alias ClashOfClansSlackbot.Repositories.ClashCaller.ClashCallerEntry
  @callback start_war(Integer.t, String.t, String.t) :: Tuple.t
  @callback overview(String.t) :: [%ClashCallerEntry{}]
  @callback reserve_attack(Integer.t, String.t, String.t) :: String.t
  @callback register_attack(String.t, Integer.t, Integer.t, Integer.t) :: String.t
end
