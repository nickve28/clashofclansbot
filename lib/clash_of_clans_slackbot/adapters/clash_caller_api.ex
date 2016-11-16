defmodule ClashOfClansSlackbot.Adapters.ClashCallerAPI do
  alias ClashOfClansSlackbot.Repositories.ClashCaller.{Request, ClashCallerEntry}
  @behaviour ClashOfClansSlackbot.Behaviors.WarAPI

  @base_url "http://clashcaller.com/"
  @api @base_url <> "api.php"
  @form_headers ["Accept": "application/x-www-form-urlencoded",
                 "Content-Type": "application/x-www-form-urlencoded"]

  def start_war(name, ename, size) do
    {:ok, req} = Request.construct(name, ename, size)
    request_form = req
      |> Request.to_form_body

    result = HTTPotion.post(@api, [headers: @form_headers,
                                   body: request_form])
    case HTTPotion.Response.success? result do
      true  -> { :ok, @base_url <> result.body }
      false -> { :err, result }
    end
  end

  def overview(warcode) do
    {:ok, req} = Request.construct(warcode)
    request_form = req
      |> Request.to_form_body

    result = HTTPotion.post @api, [headers: @form_headers,
                                   body: request_form]
    case HTTPotion.Response.success? result do
      true  -> { :ok, convert_to_overview(result.body) }
      false -> { :err, result }
    end
  end

  defp convert_to_overview("<error>Invalid War ID.</error>" = error), do: error

  defp convert_to_overview(body) do
    Poison.Parser.parse!(body)
      |> Map.get("calls")
      |> Enum.map(&(ClashCallerEntry.to_clashcaller_entry &1))
  end

  def reserve_attack(target, name, warcode) do
    {:ok, req} = Request.construct(target, name, warcode)
    request_form = req
      |> Request.to_form_body

    result = HTTPotion.post @api, [headers: @form_headers,
                                   body: request_form]
    case HTTPotion.Response.success? result do
      true  -> { :ok, result.body }
      false -> { :err, result }
    end
  end

  def register_attack(warcode, target, attack_position, stars) do
    {:ok, req} = Request.construct(warcode, target, attack_position, stars)
    request_form = req
      |> Request.to_form_body

    result = HTTPotion.post @api, [headers: @form_headers,
                                   body: request_form]
    case HTTPotion.Response.success? result do
      true  -> { :ok, result.body }
      false -> { :err, result }
    end
  end

  def remove_reservation({target, name, warcode, position}) do
    {:ok, req} = Request.construct({target, name, warcode, position}, "DELETE")
    request_form = req
      |> Request.to_form_body
    result = HTTPotion.post @api, [headers: @form_headers,
                                   body: request_form]
    case HTTPotion.Response.success? result do
      true  -> { :ok, result.body }
      false -> { :err, result }
    end
  end
end

