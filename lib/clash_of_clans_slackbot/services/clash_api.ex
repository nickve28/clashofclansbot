defmodule ClashOfClansSlackbot.Services.ClashApi do
  def start_link(clantag, token) do
    Agent.start_link(fn -> [token: token, clantag: clantag, players: []] end, name: __MODULE__)
  end

  def poll do
    {token, clantag} = Agent.get(__MODULE__, fn x -> {x[:token], x[:clantag]} end)
    {:ok, players} = ClashOfClansSlackbot.Repositories.ClashApi.poll_donations(clantag, token)
    Agent.update(__MODULE__, fn x -> Keyword.put(x, :players, players) end)
  end

  def list do
    Agent.get(__MODULE__, fn x -> x[:players] end)
  end
end
