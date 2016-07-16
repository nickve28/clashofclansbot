defmodule SlackClient do
  use Slack

  def handle_connect(slack) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok }
  end

  def handle_message(message = %{hidden: true}, slack) do #This is to prevent the hidden url messages from crashing everything
    { :ok }
  end

  def handle_message(message = %{type: "message"}, slack) do
    text = message.text
      |> String.downcase
    { status, response } = MessageParser.parse_response text
    if status === :ok do
      send_message(response, message.channel, slack)
    end
    { :ok }
  end

  def handle_message(_message, slack) do
    { :ok }
  end

  def handle_info(_, _), do: :ok
end
