defmodule Tasks.PollClashApi do
  def run() do
    ClashOfClansSlackbot.Services.ClashApi.poll
  end
end
