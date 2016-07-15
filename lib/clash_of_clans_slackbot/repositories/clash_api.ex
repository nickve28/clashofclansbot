defmodule ClashOfClansSlackbot.Repositories.ClashApi do
  @base_url "https://api.clashofclans.com/v1/"
  @base_headers ["Accept": "application/json",
                 "Content-Type": "application/json"]

  def encode_tag(clantag) do
    String.replace clantag, "#", "%23"
  end

  def members_endpoint(clantag) do
    clantag
      |> encode_tag
      |> (fn tag -> @base_url <> "clans/" <> tag <> "/members" end).()
  end

  def get_members(url, token) do
    headers = Keyword.merge(["Authorization": "Bearer #{token}"], @base_headers)
    HTTPotion.get(url, headers: headers)
  end

  def to_player_maps(response) do
    players = response
      |> Map.get(:body)
      |> Poison.decode!
      |> Map.get("items")
      |> Enum.map(fn player_data -> ClashOfClansSlackbot.Models.Player.to_player(player_data) end)
    { :ok, players }
  end

  def poll_donations(clantag, token) do
    clantag
      |> members_endpoint
      |> get_members(token)
      |> to_player_maps
  end
end
