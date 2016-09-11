defmodule ClashOfClansSlackbot.Services.ClashCaller do
  @mapping_stars  %{
    "No attack" => 0,
    "0 stars" => 1,
    "1 star" => 2,
    "2 stars" => 3,
    "3 stars" => 4
  }


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
    warcode = parse_war_code
    {:ok, request} = Clashcaller.Request.construct(warcode)
    { :ok, reservations } = Clashcaller.Request.to_form_body(request)
                              |> Clashcaller.overview
    result = reservations
      |> Enum.filter(&(&1.target === target))
    { :ok, result }
  end

  def reserve(target, name) do
    warcode = parse_war_code
    { :ok, req } = Clashcaller.Request.construct(target, name, warcode)
    Clashcaller.Request.to_form_body(req)
      |> Clashcaller.reserve_attack
  end

  def overview do
    warcode = parse_war_code
    {:ok, request} = Clashcaller.Request.construct(warcode)
    {:ok, reservations} = request
      |> Clashcaller.Request.to_form_body
      |> Clashcaller.overview
    reservations
      |> to_overview
  end

  defp to_overview([]), do: {:ok, []}

  defp overview_sorter(x, y) do
    case (x.target === y.target) do
      true -> @mapping_stars[x.stars] > @mapping_stars[y.stars]
      _ -> x.target < y.target
    end
  end

  defp to_overview(reservations) do
    reservations = reservations
      |> Enum.sort(&overview_sorter/2)
      |> Enum.uniq_by(fn %{target: target} -> target end)
    {:ok, reservations}
  end

  def attack(target, player, stars) do
    warcode = parse_war_code
    { :ok, request } = Clashcaller.Request.construct(warcode)
    { :ok, reservations } = request
                              |> Clashcaller.Request.to_form_body
                              |> Clashcaller.overview
    attacker = reservations
                 |> Enum.filter(&(&1.target === target))
                 |> find_attack_position(player)
    handle_attack_registration(attacker, warcode, target, stars)
  end

  defp parse_war_code do
    Storage.get_war_url
      |> String.split("/")
      |> List.last
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
