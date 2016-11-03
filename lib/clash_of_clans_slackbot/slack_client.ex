defmodule SlackClient do
  use Slack
  require Logger

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{hidden: true}, slack, state) do #This is to prevent the hidden url messages from crashing everything
    { :ok, state }
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    text = message.text
      |> String.downcase

    Logger.info("Received #{text}")
    { status, response } = MessageParser.parse_response text
    if status === :ok do
      send_message(response, message.channel, slack)
    end
    { :ok, state }
  end

  def handle_event(message, _slack, state) do
    Logger.info("Received #{Poison.encode! message}")
    { :ok, state }
  end

  def handle_close({:error, :keepalive_timeout}, _slack, _state) do
    exit {:error, :keepalive_timeout}
  end

  def handle_close(reason, slack, state) do
    Poison.encode!(reason)
      |> Logger.error
    {:ok, state}
  end

  def handle_info(message, _, state) do
    msg = Poison.encode!(message)
    Logger.error("handle_info received #{msg}")
    { :ok, state }
  end
end
