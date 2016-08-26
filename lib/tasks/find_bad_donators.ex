defmodule Tasks.FindBadDonators do
  require Logger

  defp post_message(message, channel_id, token) do
    Logger.info("Sending #{message}")
    Slack.Web.Chat.post_message(channel_id, message, %{token: token, as_user: true})
  end

  def run() do
    channel_name = Application.get_env(:clash_of_clans_slackbot, :post_channel) || "bottesting"
    token = Application.get_env :clash_of_clans_slackbot, :token
    channel_id = Task.async(fn -> Slack.Web.Channels.list(%{token: token})
                |> Map.get("channels")
                |> Enum.find(fn x -> x["name"] == channel_name end)
                |> Map.get("id")
               end)
    bad_donators = ClashOfClansSlackbot.Services.ClashApi.list_bad_donators
      |> Enum.map(fn %{name: name, donations: donations, donations_received: donations_received} -> "#{name}: #{donations} / #{donations_received}" end)
    ["Now showing all people with bad donations, in the format: name: donations / donations received..." | bad_donators]
      |> Enum.join("\n")
      |> post_message(Task.await(channel_id), token)
  end
end
