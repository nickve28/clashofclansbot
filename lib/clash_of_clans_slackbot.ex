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
