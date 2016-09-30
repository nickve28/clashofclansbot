defmodule ClashOfClansSlackbot.Adapters.MockClashCallerAPI do
  @base_url "http://clashcaller.com/"

  def start_war(10, "error", ename) do
    {:err, %{code: 400}}
  end

  def start_war(size, name, ename) do
    {:ok, @base_url <> "war/3tynq"}
  end
end
