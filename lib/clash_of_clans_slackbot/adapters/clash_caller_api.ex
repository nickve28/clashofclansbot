defmodule ClashOfClansSlackbot.Adapters.ClashCallerAPI do
  @base_url "http://clashcaller.com/"
  @api @base_url <> "api.php"
  @form_headers ["Accept": "application/x-www-form-urlencoded",
                 "Content-Type": "application/x-www-form-urlencoded"]

  def start_war(name, ename, size) do
    {:ok, req} = Clashcaller.Request.construct(name, ename, size)
    request_form = req
      |> Clashcaller.Request.to_form_body

    result = HTTPotion.post(@api, [headers: @form_headers,
                                   body: request_form])
    case HTTPotion.Response.success? result do
      true  -> { :ok, @base_url <> result.body }
      false -> { :err, result }
    end
  end
end

