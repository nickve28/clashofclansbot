defmodule ClashOfClansSlackbot.Services.ClashCaller do
  def create_war(name, ename, size) do
    {:ok, req} = Clashcaller.Request.construct(name, ename, size)

    case start_war(req) do
      {:ok, url} ->
        Storage.save_url(url)
        {:ok, url}
      {:error, msg} -> {:error, msg}
    end
  end

  defp start_war(request) do
    request
      |> Clashcaller.Request.to_form_body()
      |> Clashcaller.start_war()
  end
end
