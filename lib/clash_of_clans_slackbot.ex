defmodule Validator do
  def validate_token(token) do
    case !!token do
      true -> { :ok, token }
      _    -> { :err, "No token provided" }
    end
  end
end

defmodule MessageParser do
  def parse_response(message) do
    { :ok, message }
  end
end

defmodule SlackClient do
  use Slack
  import MessageParser

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    text = message.text
    { :ok, message_to_send } = MessageParser.parse_response text
    send_message(message_to_send, message.channel, slack)

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
