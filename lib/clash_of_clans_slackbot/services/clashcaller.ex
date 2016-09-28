defmodule ClashOfClansSlackbot.Services.ClashCaller do
  use GenServer

  @mapping_stars  %{
    "No attack" => 0,
    "0 stars" => 1,
    "1 star" => 2,
    "2 stars" => 3,
    "3 stars" => 4
  }

  def start_link() do
    GenServer.start_link(ClashOfClansSlackbot.Services.ClashCaller, [], name: __MODULE__)
  end

  def init(_args) do
    url = Storage.get_war_url
    {:ok, {url, []}}
  end

  def create_war(name, ename, size) do
    GenServer.call(__MODULE__, {:create_war, {name, ename, size}})
  end

  def handle_call({:create_war, {name, ename, size}}, _from, state) do
    {:ok, req} = Clashcaller.Request.construct(name, ename, size)

    war_result = case start_war(req) do
      {:ok, url} ->
        Storage.save_url(url)
        result = {:ok, url}
        {:reply, result, {url, []}}
      {:error, msg} ->
        result = {:error, msg}
        {:reply, result, state}
    end
  end

  defp start_war(request) do
    request
      |> Clashcaller.Request.to_form_body()
      |> Clashcaller.start_war()
  end

  def get_current_war_url, do: GenServer.call(__MODULE__, :war)

  def handle_call(:war, _from, {url, _} = state) do
    {:reply, {:ok, url}, state}
  end

  def reservations(target) do
    GenServer.call(__MODULE__, {:reservations, target})
  end

  def handle_call({:reservations, target}, _from, {url, _} = state) do
    warcode = parse_war_code(url)
    {:ok, request} = Clashcaller.Request.construct(warcode)
    { :ok, reservations } = Clashcaller.Request.to_form_body(request)
                              |> Clashcaller.overview
    result = reservations
      |> Enum.filter(&(&1.target === target))
    {:reply, { :ok, result }, state}
  end

  def reserve(target, name) do
    GenServer.call(__MODULE__, {:reserve, target, name})
  end

  def handle_call({:reserve, target, name}, _from, {url, _} = state) do
    warcode = parse_war_code(url)
    { :ok, req } = Clashcaller.Request.construct(target, name, warcode)
    {:ok, reservations} = Clashcaller.Request.to_form_body(req)
      |> Clashcaller.reserve_attack
    {:reply, {:ok, reservations}, state}
  end

  def player_overview(player_name) do
    GenServer.call(__MODULE__, {:player_overview, player_name})
  end

  def handle_call({:player_overview, player_name}, _from, {url, current_reservations}) do
    warcode = parse_war_code(url)
    {:ok, request} = Clashcaller.Request.construct(warcode)
    {:ok, reservations} = request
      |> Clashcaller.Request.to_form_body
      |> Clashcaller.overview
    {:ok, filtered_reservations} = reservations
      |> to_overview(fn %{player: name} -> name === player_name end)
    {:reply, {:ok, filtered_reservations}, {url, filtered_reservations}}
  end

  def overview do
    GenServer.call(__MODULE__, :overview)
  end

  def handle_call(:overview, _from, {url, current_reservations}) do
    warcode = parse_war_code(url)
    {:ok, request} = Clashcaller.Request.construct(warcode)
    {:ok, reservations} = request
      |> Clashcaller.Request.to_form_body
      |> Clashcaller.overview
    {:ok, filtered_reservations} = reservations
      |> to_overview
    {:reply, {:ok, filtered_reservations}, {url, reservations}}
  end

  defp to_overview(reservations, filter_fun) do
    reservations = reservations
      |> Enum.filter(filter_fun)
      |> Enum.sort(&overview_sorter/2)
    {:ok, reservations}
  end

  defp to_overview([], _), do: {:ok, []}
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
    GenServer.call(__MODULE__, {:attack, target, player, stars})
  end

  def handle_call({:attack, target, player, stars}, _from, {url, _} = state) do
    warcode = parse_war_code(url)
    { :ok, request } = Clashcaller.Request.construct(warcode)
    { :ok, reservations } = request
                              |> Clashcaller.Request.to_form_body
                              |> Clashcaller.overview
    attacker = reservations
                 |> Enum.filter(&(&1.target === target))
                 |> find_attack_position(player)
    response = handle_attack_registration(attacker, warcode, target, stars)
    {:reply, response, state}
  end

  defp parse_war_code(code) do
    code
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
