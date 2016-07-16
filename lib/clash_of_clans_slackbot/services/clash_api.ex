defmodule ClashOfClansSlackbot.Services.ClashApi do
  def start_link(clantag, token) do
    Agent.start_link(fn -> [token: token, clantag: clantag, players: []] end, name: __MODULE__)
  end

  def poll do
    {token, clantag} = Agent.get(__MODULE__, fn x -> {x[:token], x[:clantag]} end)
    {:ok, players} = ClashOfClansSlackbot.Repositories.ClashApi.poll_donations(clantag, token)
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

  def list_bad_donators do
    list(fn %{donations: donations, donations_received: donations_received} ->
           score_donations(donations, donations_received) <= 0.33 end)
  end

  def list(f) do
    Agent.get(__MODULE__, fn x -> x[:players] |> Enum.filter(f) end)
  end
  def list do
    Agent.get(__MODULE__, fn x -> x[:players] end)
  end
end
