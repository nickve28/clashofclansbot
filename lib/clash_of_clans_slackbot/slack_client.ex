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
end
