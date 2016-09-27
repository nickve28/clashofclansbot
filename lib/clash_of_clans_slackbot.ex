defmodule ClashOfClansSlackbot do
  import Supervisor.Spec

  def authenticate(token) do
    case Validator.validate_token token do
      { :err, err_msg } -> { :err, err_msg }
      { :ok, _ } -> token
    end
  end

  def start(_type, _args) do
    token = Application.get_env :clash_of_clans_slackbot, :token
    clashapi_token = Application.get_env :clash_of_clans_slackbot, :clashapi_token
    clantag = Application.get_env :clash_of_clans_slackbot, :clantag
    case authenticate token do
      { :err, err_msg } -> IO.puts err_msg
      _ -> children = [
          worker(SlackClient, [token]),
          worker(ClashOfClansSlackbot.Services.ClashApi, [clantag, clashapi_token]),
          worker(ClashOfClansSlackbot.Services.ClashCaller, [])
        ]
        Supervisor.start_link(children, strategy: :one_for_one)
    end
  end
end
