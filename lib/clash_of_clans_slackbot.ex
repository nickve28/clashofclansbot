defmodule Validator do
  def validate_token(token) do
    case !!token do
      true -> { :ok, token }
      _    -> { :err, "No token provided" }
    end
  end
end

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
    Clashcaller.Request.to_form_body(req)
      |> Clashcaller.start_war
  end

  defp parse_action(_command, _) do
    { :no_content, _command }
  end

end

defmodule SlackClient do
  use Slack
  import MessageParser

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_message(message = %{hidden: true}, slack, state) do #This is to prevent the hidden url messages from crashing everything
    { :ok, state ++ [message.message.text] }
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    text = message.text
    { status, response } = MessageParser.parse_response text
    if status === :ok do
      send_message(response, message.channel, slack)
    end
    {:ok, state ++ [message.text]}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def start(token) do
    start_link(token, [])
  end
end

defmodule ClashOfClansSlackbot do
  import SlackClient

  def authenticate(token) do
    case Validator.validate_token token do
      { :err, err_msg } -> { :err, err_msg }
      { :ok, _ } -> SlackClient.start(token)
    end
  end

  def main(args) do
    token = Application.get_env :clash_of_clans_slackbot, :token
    case authenticate token do
      { :err, err_msg } -> IO.puts err_msg
      _ -> IO.puts "Token authenticated"
    end
  end
end
