defmodule ClashOfClansSlackbot.Services.ClashApi do
  @donation_treshold Application.get_env(:clash_of_clans_slackbot, :donation_treshold, 0.66)
  @min_donations Application.get_env(:clash_of_clans_slackbot, :min_donations, 500)
  @player_links Application.get_env(:clash_of_clans_slackbot, :player_links, %{})

  def start_link(clantag, token) do
    Agent.start_link(fn -> [token: token, clantag: clantag, players: []] end, name: __MODULE__)
  end

  defp map_playername(player) do
    case Map.get(@player_links, player.name, nil) do
      nil -> player
      main_name -> %{player | name: main_name}
    end
  end

  defp fold_player_entries({name, entries}) do
    total_donations = entries
      |> Enum.map(fn player -> player.donations end)
      |> Enum.sum
    total_donations_received = entries
      |> Enum.map(fn player -> player.donations_received end)
      |> Enum.sum
    %ClashOfClansSlackbot.Models.Player{name: name, donations: total_donations, donations_received: total_donations_received}
  end

  def poll do
    {token, clantag} = Agent.get(__MODULE__, fn x -> {x[:token], x[:clantag]} end)
    {:ok, players} = ClashOfClansSlackbot.Repositories.ClashApi.poll_donations(clantag, token)
    players = players
      |> Enum.map(&map_playername/1)
      |> Enum.group_by(&(&1.name))
      |> Enum.map(&fold_player_entries/1)
    Agent.update(__MODULE__, fn x -> Keyword.put(x, :players, players) end)
  end

  defp score_donations(x, 0) do
    x
  end

  defp score_donations(0, _) do
    0
  end

  defp score_donations(donations, donations_received) do
    donations / donations_received
  end

  defp filter_bad_donators(players) do
    Enum.filter(players, fn %{donations: donations, donations_received: donations_received} ->
      donations < @min_donations || score_donations(donations, donations_received) <= @donation_treshold end)
  end

  def list_bad_donators, do: list(&filter_bad_donators/1)

  def list(f), do: Agent.get(__MODULE__, fn x -> (x[:players]) |> f.() end)

  def list, do: list(fn players -> players end)
end
