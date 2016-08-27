defmodule ClashOfClansSlackbot.Services.ClashCaller do
  @vsn "0"

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

  def reservations(target) do
    { :ok, request } = Storage.get_war_url
      |> String.split("/")
      |> List.last
      |> Clashcaller.Request.construct
    { :ok, reservations } = Clashcaller.Request.to_form_body(request)
                              |> Clashcaller.overview
    result = reservations
      |> Enum.filter(&(&1.target === target))
    { :ok, result }
  end

  def reserve(target, name) do
    warcode = Storage.get_war_url
      |> String.split("/")
      |> List.last
    { :ok, req } = Clashcaller.Request.construct(target, name, warcode)
    Clashcaller.Request.to_form_body(req)
      |> Clashcaller.reserve_attack
  end
end
