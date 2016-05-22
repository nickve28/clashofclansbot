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
    parsed_names = Enum.at(names, 0)
      |> String.split(~r/"/)
      |> Enum.reject(&(&1 in @empty_values))
      |> Enum.map(&(String.strip &1))
    name = Enum.at parsed_names, 0
    ename = Enum.at parsed_names, 1
    { :ok, req } = Clashcaller.Request.construct(name, ename, parsed_size)
    { :ok, url } = Clashcaller.Request.to_form_body(req)
                     |> Clashcaller.start_war
    #write to db
    Storage.save_url(url)

    { :ok, "I started the war, it can be found here: #{url}" }
  end

  defp parse_action("!reservations", []) do
    { :no_content, "!reservations" }
  end

  defp parse_action("!reservations", parameters) do
    { target, _ } = Integer.parse(parameters)
    { :ok, request } = Storage.get_war_url
      |> String.split("/")
      |> List.last
      |> Clashcaller.Request.construct
    { :ok, reservations } = Clashcaller.Request.to_form_body(request)
                              |> Clashcaller.overview
    result = reservations
      |> Enum.filter(&(&1.target === target))
      |> to_output(target)
    { :ok, result }
  end

  defp to_output([], target) do
    "No reservations known for #{target}"
  end

  defp to_output(reservations, target) do
    reservations
      |> Enum.map(fn entry -> "Reservation for #{entry.player} with #{entry.stars}" end)
      |> Enum.join("\n")
  end

  defp parse_action("!war", _parameters) do
    { :ok, "The current war url is #{Storage.get_war_url}" }
  end

  defp parse_action("!reserve", parameters) do
    [target, name] = String.split parameters, " ", parts: 2
    {target, _} = Integer.parse target
    warcode = Storage.get_war_url
      |> String.split("/")
      |> List.last
    { :ok, req } = Clashcaller.Request.construct(target, name, warcode)
    Clashcaller.Request.to_form_body(req)
      |> Clashcaller.reserve_attack
  end

  defp parse_action("!attack", parameters) do
    [target, player, stars] = String.split(parameters, " ")
    register_attack(Integer.parse(target), player, Integer.parse(stars))
  end

  defp register_attack(target, player, stars) do
    warcode = Storage.get_war_url
      |> String.split("/")
      |> List.last
    { :ok, request } = Clashcaller.Request.construct(warcode)
    { :ok, reservations } = request
                              |> Clashcaller.Request.to_form_body
                              |> Clashcaller.overview
    attack_position = reservations
                        |> Enum.filter(&(&1.target === target))
                        |> find_attack_position(player)
    { :ok, attack_request } = Clashcaller.Request.construct(warcode, target, attack_position, stars)
    attack_request
      |> Clashcaller.Request.to_form_body
      |> Clashcaller.register_attack
  end

  defp find_attack_position(reservations, player) do
    reservations
      |> Enum.map(fn reservation -> reservation.value === player end)
      |> Enum.at(0)
  end

  defp parse_action(_command, _) do
    { :no_content, _command }
  end

end


