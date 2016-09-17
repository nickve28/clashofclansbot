defmodule MessageParser do
  @empty_values ["", ", ", " "]

  def parse_response(message) do
    message
      |> String.split(" ", parts: 2)
      |> parse_args
  end

  defp parse_args([command, parameters]) do
    parse_action command, parameters
  end

  defp parse_args([command]), do: parse_action(command, [])

  defp parse_action("!overview", player_name) when is_binary(player_name) do
    case ClashOfClansSlackbot.Services.ClashCaller.player_overview(player_name) do
      {:ok, []} -> {:ok, "Player #{player_name} has no reservations."}
      {:ok, reservations} -> {:ok, format_player_entries(reservations, player_name)}
      _ -> {:ok, "Something went wrong!"}
    end
  end

  defp parse_action("!overview", empty) when empty === "" do
    case ClashOfClansSlackbot.Services.ClashCaller.overview do
      {:ok, []} -> {:ok, "No reservations have been made yet"}
      {:ok, entries} -> {:ok, format_entries(entries)}
      {:err, _} -> {:ok, "Something went wrong!"}
      _ -> {:ok, "Message could not be processed"}
    end
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

  defp parse_action("!reservations", []), do: { :no_content, "!reservations" }

  defp parse_action("!reservations", parameters) do
    { target, _ } = Integer.parse(parameters)

    case ClashOfClansSlackbot.Services.ClashCaller.reservations(target) do
      {:ok, reservations} -> {:ok, to_output(reservations)}
      {:error, _reason} -> {:ok, "I couldn't get the reservations!"}
    end
  end

  defp parse_action("!war", _parameters) do
    case ClashOfClansSlackbot.Services.ClashCaller.get_current_war_url() do
      {:ok, url} -> {:ok, "The current war url is #{url}"}
      {:error, _reason} -> {:ok, "Something went wrong while fetching the war url."}
    end
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
    {target, _} = Integer.parse(target)
    {stars, _} = Integer.parse(stars)

    case ClashOfClansSlackbot.Services.ClashCaller.attack(target, player, stars) do
      {:ok, msg} -> {:ok, msg}
      {:error, :enoreservation} -> {:ok, "No reservation found for that player"}
      {:error, _} -> {:ok, "I wasn't able to process that request!"}
    end
  end

  defp parse_action(command, _), do: { :no_content, command }



  defp format_player_entries(reservations, player_name) do
    initial_message = "Reservations made by #{player_name}:"
    reservation_overview_text = reservations
      |> Enum.map(fn %{stars: stars, target: target} -> "#{stars} on base number #{target}" end)
    [initial_message | reservation_overview_text]
      |> Enum.join("\n")
  end

  defp format_entries(entries) do
    text_entries = entries
      |> Enum.map(fn %{player: name, target: target, stars: stars} ->
        "Player #{name} has the best score on #{target} with: #{stars}"
      end)
    ["Now showing the overview of the current war:" | text_entries]
      |> Enum.join("\n")
  end

  defp to_output([]), do: "No reservations known for this target"

  defp to_output(reservations) do
    reservations
      |> Enum.map(fn entry -> "Reservation for #{entry.player} with #{entry.stars}" end)
      |> Enum.join("\n")
  end
end
