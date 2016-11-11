defmodule ClashOfClansSlackbot.Helpers.Validator do
  def validate_token (nil) do
    { :err, "No token provided" }
  end

  def validate_token(token) do
    { :ok, token }
  end
end


