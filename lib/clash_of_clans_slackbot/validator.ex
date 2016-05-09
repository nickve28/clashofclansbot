defmodule Validator do
  def validate_token(token) do
    case !!token do
      true -> { :ok, token }
      _    -> { :err, "No token provided" }
    end
  end
end


