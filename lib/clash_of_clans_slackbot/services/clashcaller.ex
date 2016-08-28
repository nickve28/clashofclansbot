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

  def get_current_war_url, do: {:ok, Storage.get_war_url()}

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


  def attack(target, player, stars) do
    warcode = Storage.get_war_url
      |> String.split("/")
      |> List.last
    { :ok, request } = Clashcaller.Request.construct(warcode)
    { :ok, reservations } = request
                              |> Clashcaller.Request.to_form_body
                              |> Clashcaller.overview
    attacker = reservations
                 |> Enum.filter(&(&1.target === target))
                 |> find_attack_position(player)
    handle_attack_registration(attacker, warcode, target, stars)
  end

  defp handle_attack_registration(nil, _, _, _), do: {:error, :enoreservation}

  defp handle_attack_registration(%{position: attack_position}, warcode, target, stars) do
    { :ok, attack_request } = Clashcaller.Request.construct(warcode, target, attack_position, stars)
    attack_request
      |> Clashcaller.Request.to_form_body
      |> Clashcaller.register_attack
  end

  defp find_attack_position(reservations, player) do
    reservations
      |> Enum.find(fn reservation -> reservation.player === player end)
  end
end
