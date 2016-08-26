defmodule Tasks.PollClashApi do
  require Logger

  def run() do
    Logger.info("Running poll clash api..")
    ClashOfClansSlackbot.Services.ClashApi.poll
  end
end
