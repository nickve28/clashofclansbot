defmodule ClashOfClansSlackbot.Services.SlackClientTest do
  use ExUnit.Case
  alias ClashOfClansSlackbot.Services.SlackClient
  doctest SlackClient

  @tweet %{attachments: [%{author_icon: "https://pbs.twimg.com/profile_images/508012914125463552/hIWOgrFq_normal.png", author_link: "https://twitter.com/ClashofClans/status/798935262768173056", author_name: "Clash of Clans", author_subname: "@ClashofClans", fallback: "<https://twitter.com/ClashofClans|@ClashofClans>: Beautiful Archer drawing! Featured fan art by Fernando Antúnez (<http://ferj-117.deviantart.com/>) <https://pbs.twimg.com/media/CxZjU5kWgAAzHri.jpg>", footer: "Twitter", footer_icon: "https://a.slack-edge.com/6e067/img/services/twitter_pixel_snapped_32.png", from_url: "https://twitter.com/ClashofClans/status/798935262768173056", id: 1, image_bytes: 162842, image_height: 1012, image_url: "https://pbs.twimg.com/media/CxZjU5kWgAAzHri.jpg", image_width: 790, pretext: "<https://twitter.com/ClashofClans/status/798935262768173056>", service_name: "twitter", service_url: "https://twitter.com/", text: "Beautiful Archer drawing! Featured fan art by Fernando Antúnez (<http://ferj-117.deviantart.com/>) <https://pbs.twimg.com/media/CxZjU5kWgAAzHri.jpg>", ts: 1479315984}], bot_id: "B2Z97343H", channel: "C0M8ABL3E", subtype: "bot_message", team: "T0M8G9WGG", ts: "1479315985.000004", type: "message", user_team: "T0M8G9WGG"}

  test "Receiving a tweet message should not crash" do
    #TODO test this more functionally
    result = SlackClient.handle_event(@tweet, %{}, %{})
    expected = {:ok, %{}}
    assert result == expected
  end
end
