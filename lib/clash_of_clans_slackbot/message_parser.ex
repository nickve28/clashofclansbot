defmodule MessageParser do
  @empty_values ["", ", ", " "]

  def parse_response(message) do
    [command, parameters] = String.split message, " ", parts: 2
    parse_action command, parameters
  end

  defp parse_action(_command="!startwar", parameters) do
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
    Task.async(fn -> Storage.save_url(url) end)
    { :ok, "I started the war, it can be found here: #{url}" }
  end

  defp parse_action(_command, _) do
    { :no_content, _command }
  end

end


