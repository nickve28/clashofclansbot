defmodule SlackClient do
  use Slack
  require Logger

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

    Logger.info("Received #{text}")
    { status, response } = MessageParser.parse_response text
    if status === :ok do
      send_message(response, message.channel, slack)
    end
    { :ok }
  end

  def handle_message(message, _slack) do
    Logger.info("Received #{Poison.encode! message}")
    { :ok }
  end

  def handle_close(reason, socket_tuple) do
    Poison.encode!(reason)
      |> Logger.error
    socket_tuple
      |> Tuple.to_list
      |> Enum.join(", ")
      |> Logger.error
    :ok
  end

  def handle_info(message, _) do
    msg = Poison.encode!(message)
    Logger.error("handle_info received #{msg}")
    :ok
  end
end
