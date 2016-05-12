defmodule Clashcaller.Request do
  @war_sizes [10, 15, 20, 25, 30, 40, 50]

  @doc """
  Constructs a CREATE_WAR request for clashcaller, returned as list

  ## Examples
      iex> Clashcaller.Request.construct("Atomic Bullies", "Dizzies", 10)
      { :ok , [REQUEST: "CREATE_WAR", cname: "Atomic Bullies", ename: "Dizzies", size: "10", timers: "0", searchable: "false"] }
  """
  def construct(clan_name, enemy_clan_name, size) when size in @war_sizes do
    { :ok, [REQUEST: "CREATE_WAR", cname: clan_name, ename: enemy_clan_name, size: Integer.to_string(size),
            timers: "0", searchable: "false"] }
  end

  @doc """
  Triggered when an invalid size is given

  ## Examples
      iex> Clashcaller.Request.construct("Atomic Bullies", "Dizzies", 45)
      { :err, "45 is not valid, expected one of: 10, 15, 20, 25, 30, 40, 50" }
  """
  def construct(clan_name, enemy_clan, size) when is_integer(size) do
    { :err, "#{size} is not valid, expected one of: #{Enum.join @war_sizes, ", "}" }
  end

  @doc """
  Constructs a request to reserve a target

  ## Examples
      iex> Clashcaller.Request.construct(1, "Nick", "1234")
      { :ok, [REQUEST: "APPEND_CALL", warcode: "1234", posy: "0", value: "Nick"] }
  """
  def construct(target, name, war) when is_integer(target) do
    posy = Integer.to_string(target - 1) #clashcaller deals with ypositions
    { :ok, [REQUEST: "APPEND_CALL", warcode: war, posy: posy, value: name] }
  end

  @doc """
  Construct a request to get the current war overview

  ## Examples
      iex> Clashcaller.Request.construct("1234")
      { :ok, [REQUEST: "GET_FULL_UPDATE", warcode: "1234"] }
  """
  def construct(warcode) do
    { :ok, [REQUEST: "GET_FULL_UPDATE", warcode: warcode] }
  end

  @doc """
  Converts the request parameter to a form body for form-encoded requests

  ## Examples
      iex> Clashcaller.Request.to_form_body [REQUEST: "GET_FULL_UPDATE", warcode: "1234"]
      "REQUEST=GET_FULL_UPDATE&warcode=1234"
  """
  def to_form_body(request) do
    form_req = for {k, v} <- request, into: [], do: (Atom.to_string(k) <> "=" <> v)
    Enum.join(form_req, "&")
  end
end

defmodule Clashcaller.ClashcallerEntry do
  @derive [Poison.Encoder]
  defstruct [:player, :stars, :target]

  def to_clashcaller_entry(clashcaller_output_json) do
    { parsed_posy, _ } = Integer.parse clashcaller_output_json["posy"]
    target = parsed_posy + 1 #clashcaller mapping

    { stars, _ } = Integer.parse clashcaller_output_json["stars"]
    mapped_stars = convert(stars)
    %Clashcaller.ClashcallerEntry{
      player: clashcaller_output_json["playername"],
      stars: mapped_stars,
      target: target
    }
  end

  def convert(1) do
    "No attack"
  end

  def convert(2) do
    "0 stars"
  end

  def convert(3) do
    "1 star"
  end

  def convert(4) do
    "2 stars"
  end

  def convert(5) do
    "3 stars"
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

  def reserve_attack(request_form) do
    result = HTTPotion.post @api, [headers: @form_headers,
                                   body: request_form]
    case HTTPotion.Response.success? result do
      true  -> { :ok, result.body }
      false -> { :err, result }
    end
  end

  def overview(request_form) do
    result = HTTPotion.post @api, [headers: @form_headers,
                                   body: request_form]
    case HTTPotion.Response.success? result do
      true  -> { :ok, convert_to_overview(result.body) }
      false -> { :err, result }
    end
  end

  defp convert_to_overview(body) do
    Poison.Parser.parse!(body)
      |> Map.get("calls")
      |> Enum.map(&(Clashcaller.ClashcallerEntry.to_clashcaller_entry &1))
  end
end
