defmodule Clashcaller.Request do
  @war_sizes [10, 15, 20, 25, 30, 40, 50]

  def construct(clan_name, enemy_clan_name, size) when size in @war_sizes do
    { :ok, [REQUEST: "CREATE_WAR", cname: clan_name, ename: enemy_clan_name, size: Integer.to_string(size),
            timers: "0", searchable: "false"] }
  end

  def construct(clan_name, enemy_clan, size) when is_integer(size) do
    { :err, "#{size} is not valid, expected one of: #{Enum.join @war_sizes, ", "}" }
  end

  def to_form_body(request) do
    form_req = for {k, v} <- request, into: [], do: (Atom.to_string(k) <> "=" <> v)
    Enum.join(form_req, "&")
  end
end

defmodule Clashcaller do
  @base_url "http://clashcaller.com/"
  @api @base_url <> "api.php"
  @form_headers ["Accept": "application/x-www-form-urlencoded",
                 "Content-Type": "application/x-www-form-urlencoded"]

  def start_war(request_form) do
    result = HTTPotion.post @api, [headers: @form_headers,
                                   body: request_form]
    case HTTPotion.Response.success? result do
      true  -> { :ok, @base_url <> result.body }
      false -> { :err, result }
    end
  end
end
