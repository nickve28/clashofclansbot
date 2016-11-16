defmodule ClashOfClansSlackbot.Services.ClashCaller do
  alias ClashOfClansSlackbot.Repositories
  alias ClashOfClansSlackbot.Repositories.Storage
  alias ClashOfClansSlackbot.Repositories.ClashCaller.ClashCallerEntry

  use GenServer

  @time_module Application.get_env(:clash_of_clans_slackbot, :time_module)

  @mapping_stars %{
    "No attack" => 0,
    "0 stars" => 1,
    "1 star" => 2,
    "2 stars" => 3,
    "3 stars" => 4
  }

  #public API
  def start_link() do
    GenServer.start_link(ClashOfClansSlackbot.Services.ClashCaller, [], name: __MODULE__)
  end

  def init(_args) do
    url = Storage.get_war_url
    force_sync_time_tuple = {300, 0}

    state = {url, [], {}}
      |> update_state(force_sync_time_tuple)
    {:ok, state}
  end

  def create_war(name, ename, size) do
    GenServer.call(__MODULE__, {:create_war, {name, ename, size}})
  end

  defp start_war({name, ename, size}) do
    Repositories.ClashCaller.start_war(name, ename, size)
  end

  def get_current_war_url, do: GenServer.call(__MODULE__, :war)

  def reservations(target) do
    GenServer.call(__MODULE__, :sync)
    GenServer.call(__MODULE__, {:reservations, target})
  end

  def reserve(target, name) do
    GenServer.call(__MODULE__, :sync)
    GenServer.call(__MODULE__, {:reserve, target, name})
  end

  def attack(target, player, stars) do
    GenServer.call(__MODULE__, :sync)
    GenServer.call(__MODULE__, {:attack, target, player, stars})
  end

  def player_overview(player_name) do
    GenServer.call(__MODULE__, :sync)
    GenServer.call(__MODULE__, {:player_overview, player_name})
  end

  defp register_reservation(reservations, {target, name, _warcode} = war_data) do
    existing_reservations = for %{player: ^name, target: ^target} = reservation <- reservations, do: reservation
    confirm_reservation(existing_reservations, reservations, war_data)
  end

  def overview do
    GenServer.call(__MODULE__, :sync)
    GenServer.call(__MODULE__, :overview)
  end

  def remove_reservation(target, player) do
    GenServer.call(__MODULE__, :sync)
    GenServer.call(__MODULE__, {:remove_reservation, target, player})
  end

  defp update_state(state, {current_time, last_synced_time}) when (current_time - last_synced_time) < 300, do: state

  defp update_state({{:error, :enowarurl}, _, _}, _) do
    {{:error, :enowarurl}, [], {300, 0}}
  end

  defp update_state({url, _, _}, _) do
    warcode = parse_war_code(url)
    time = @time_module.local_time

    case Repositories.ClashCaller.overview(warcode) do
      {:ok, new_reservations} -> {url, new_reservations, time}
      {:error, _} -> {{:error, :enowarurl}, [], time}
    end
  end

  defp confirm_reservation([], reservations, {target, name, warcode}) do
    {:ok, "<success>"} = Repositories.ClashCaller.reserve_attack(target, name, warcode)

    position = reservations
      |> Enum.filter(fn %{target: r_target} -> r_target === target end)
      |> Enum.count

    %ClashCallerEntry{player: name, target: target, stars: "No attack", position: position + 1}
  end

  defp confirm_reservation(_, _, _), do: {:error, :ereservationexists}

  defp update_reservations(reservations, attack) do
    for reservation <- reservations, do: update_entry(reservation, attack)
  end

  defp update_entry(%ClashCallerEntry{target: target, player: player} = player,
   %ClashCallerEntry{target: target, player: player, stars: stars}) do
    %ClashCallerEntry{player | stars: stars}
  end

  defp update_entry(old_reservation, _), do: old_reservation

  defp parse_war_code(code) do
    code
      |> String.split("/")
      |> List.last
  end

  defp handle_attack_registration(nil, _, _, _), do: {:error, :enoreservation}

  defp handle_attack_registration(%{position: attack_position}, warcode, target, stars) do
    Repositories.ClashCaller.register_attack(warcode, target, attack_position, stars)
  end

  defp find_attack_position(reservations, player) do
    reservations
      |> Enum.find(fn reservation -> reservation.player === player end)
  end

  defp to_overview([], _), do: {:ok, []}

  defp to_overview(reservations, filter_fun) do
    reservations = reservations
      |> Enum.filter(filter_fun)
      |> Enum.sort(&overview_sorter/2)
    {:ok, reservations}
  end

  defp to_overview([]), do: {:ok, []}

  defp to_overview(reservations) do
    reservations = reservations
      |> Enum.sort(&overview_sorter/2)
      |> Enum.uniq_by(fn %{target: target} -> target end)
    {:ok, reservations}
  end

  defp overview_sorter(x, y) do
    case (x.target === y.target) do
      true -> @mapping_stars[x.stars] > @mapping_stars[y.stars]
      _ -> x.target < y.target
    end
  end

  #Genserver callbacks
  def handle_call({:create_war, startwar_payload}, _from, state) do
    case start_war(startwar_payload) do
      {:ok, url} ->
        Storage.save_url(url)
        result = {:ok, url}
        {:reply, result, {url, [], @time_module.local_time}}
      {:error, msg} ->
        result = {:error, msg}
        {:reply, result, state}
    end
  end

  def handle_call(_msg, _from, {{:error, reason}, _, _} = state) do
    {:reply, {:error, reason}, state}
  end

  def handle_call(:sync, _from, {_url, _reservations, last_synced} = state) do
    current_time = @time_module.local_time
      |> :calendar.datetime_to_gregorian_seconds

    last_synced_time = last_synced
      |> :calendar.datetime_to_gregorian_seconds

    new_state = update_state(state, {current_time, last_synced_time})
    {:reply, new_state, new_state}
  end

  def handle_call(:war, _from, {url, _, _} = state) do
    {:reply, {:ok, url}, state}
  end

  def handle_call({:reservations, target}, _from, {url, _, _} = state) do
    warcode = parse_war_code(url)
    {:ok, reservations} = Repositories.ClashCaller.overview(warcode)

    result = reservations
      |> Enum.filter(&(&1.target === target))
    {:reply, { :ok, result }, state}
  end

  def handle_call({:reserve, target, name}, _from, {url, reservations, last_synced} = state) do
    warcode = parse_war_code(url)
    name = String.strip(name)

    case register_reservation(reservations, {target, name, warcode}) do
      {:error, error} -> {:reply, {:error, error}, state}
      reservation -> {:reply, {:ok, reservation}, {url, [reservation | reservations], last_synced}}
    end
  end

  def handle_call({:player_overview, player_name}, _from, {url, current_reservations, last_synced}) do
    {:ok, filtered_reservations} = current_reservations
      |> to_overview(fn %{player: name} -> name === player_name end)
    {:reply, {:ok, filtered_reservations}, {url, current_reservations, last_synced}}
  end


  def handle_call(:overview, _from, {_, reservations, _} = state) do
    {:ok, filtered_reservations} = reservations
      |> to_overview
    {:reply, {:ok, filtered_reservations}, state}
  end

  def handle_call({:remove_reservation, target, player}, _from, {url, reservations, last_synced} = state) do
    matching_reservation = for %{player: ^player, target: ^target} = reservation <- reservations, do: reservation

    case matching_reservation do
      [] -> {:reply, {:error, :enoreservation}, state}
      [%{position: position} = reservation] ->
        warcode = parse_war_code(url)
        {:ok, "<success>"} = Repositories.ClashCaller.remove_reservation({target, player, warcode, position})
        new_reservations = reservations
          |> Enum.reject(fn %{player: player_name, target: target_nr} ->
            player_name === player && target_nr === target
          end)
        {:reply, {:ok, reservation}, {url, new_reservations, last_synced}}
    end
  end

  def handle_call({:attack, target, player, stars}, _from, {url, reservations, last_synced} = state) do
    warcode = parse_war_code(url)
    attacker = reservations
                 |> Enum.filter(&(&1.target === target))
                 |> find_attack_position(player)

    updated_attack = handle_attack_registration(attacker, warcode, target, stars)

    case updated_attack do
      {:ok, "<success>"} ->
        updated_stars = Enum.at(Map.keys(@mapping_stars), stars)
        attacker = %ClashCallerEntry{attacker | stars: updated_stars}
        updated_reservations = update_reservations(reservations, attacker)
        {:reply, {:ok, attacker}, {url, updated_reservations, last_synced}}
      error -> {:reply, error, state}
    end
  end
end
