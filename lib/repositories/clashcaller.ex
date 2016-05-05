defmodule Clashcaller.Request do
  @war_sizes [10, 15, 20, 25, 30, 40, 50]

  def construct(clan_name, enemy_clan_name, size) when is_integer(size) do
    case (size in @war_sizes) do
      true ->  { :ok, [REQUEST: "CREATE_WAR", cname: clan_name, ename: enemy_clan_name, size: Integer.to_string(size),
                timers: "0", searchable: "false"] }
      _    ->  { :error, "#{size} is not valid, expected one of: #{Enum.join @war_sizes, ', '}" }
    end
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
