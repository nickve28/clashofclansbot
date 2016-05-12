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
    case authenticate token do
      { :err, err_msg } -> IO.puts err_msg
      _ -> children = [
          worker(SlackClient, [token, []])
        ]
        Supervisor.start_link(children, strategy: :one_for_one)
    end
  end
end
