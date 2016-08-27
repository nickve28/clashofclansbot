defmodule MessageParser do
  @empty_values ["", ", ", " "]

  def parse_response(message) do
    command = String.split message, " ", parts: 2
    parse_args(command)
  end

  defp parse_args([command, parameters]) do
    parse_action command, parameters
  end

  defp parse_args([command]) do
    parse_action command, []
  end

  defp parse_action("!startwar", parameters) do
    [size | names ] = String.split parameters, " ", parts: 2
    parsed_size = String.to_integer size
    parsed_names = names
      |> List.first
      |> String.split(~r/"/)
      |> Enum.reject(&(&1 in @empty_values))
      |> Enum.map(&String.strip/1)
    name = Enum.at parsed_names, 0
    ename = Enum.at parsed_names, 1

    case ClashOfClansSlackbot.Services.ClashCaller.create_war(name, ename, parsed_size) do
      { :ok, url } -> {:ok, "I started the war, it can be found here: #{url}"}
      { :error, error_msg } -> {:error, "Oh no I could not start the war! #{error_msg}"}
    end
  end

  defp parse_action("!reservations", []) do
    { :no_content, "!reservations" }
  end

  defp parse_action("!reservations", parameters) do
    { target, _ } = Integer.parse(parameters)

    case ClashOfClansSlackbot.Services.ClashCaller.reservations(target) do
      {:ok, reservations} -> {:ok, to_output(reservations)}
      {:error, _reason} -> {:ok, "I couldn't get the reservations!"}
    end
  end

  defp parse_action("!war", _parameters) do
    { :ok, "The current war url is #{Storage.get_war_url}" }
  end

  defp parse_action("!reserve", parameters) do
    [target, name] = String.split parameters, " ", parts: 2
    {target, _} = Integer.parse target

    case ClashOfClansSlackbot.Services.ClashCaller.reserve(target, name) do
      {:ok, msg} -> {:ok, msg}
      {:error, _reason} -> {:ok, "Oh no, something went wrong!"}
    end
  end

  defp parse_action("!attack", parameters) do
    [target, player, stars] = String.split(parameters, " ")
    {target, _} = Integer.parse target
    {stars, _} = Integer.parse stars
    register_attack(target, player, stars)
  end

  defp parse_action(command, _) do
    { :no_content, command }
  end

  defp to_output([]), do: "No reservations known for this target"

  defp to_output(reservations) do
    reservations
      |> Enum.map(fn entry -> "Reservation for #{entry.player} with #{entry.stars}" end)
      |> Enum.join("\n")
  end

  defp register_attack(target, player, stars) do
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

  defp handle_attack_registration(nil, _, _, _) do
    { :ok, "No reservation found for that player" }
  end

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


