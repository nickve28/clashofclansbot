defmodule Clashcaller.Request do
  def construct(clan_name, enemy_clan_name, size) do
    [REQUEST: "CREATE_WAR", cname: clan_name, ename: enemy_clan_name, size: Integer.to_string(size),
     timers: "0", searchable: "false"]
  end

  def to_form_body(request) do
    form_req = for {k, v} <- request, into: [], do: (Atom.to_string(k) <> "=" <> v)
    Enum.join(form_req, "&")
  end
end

defmodule Clashcaller do
  def start_war(request_form) do
    with base_url = "http://clashcaller.com/" do
      result = HTTPotion.post (base_url <> "api.php"), [headers: ["Accept": "application/x-www-form-urlencoded",
                                                         "Content-Type": "application/x-www-form-urlencoded"],
                                                        body: request_form]
      case HTTPotion.Response.success? result do
        true  -> { :ok, base_url <> result.body }
        false -> { :err, result.code }
      end
    end
  end
end
