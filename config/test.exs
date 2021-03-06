use Mix.Config

config :clash_of_clans_slackbot, token: "test"
config :clash_of_clans_slackbot, database: "test.sqlite3"
config :clash_of_clans_slackbot, clashapi_token: "sometoken"
config :clash_of_clans_slackbot, post_channel: "bottesting"
config :clash_of_clans_slackbot, donation_treshold: 0.33
config :clash_of_clans_slackbot, player_links: %{}
config :clash_of_clans_slackbot, war_url_filename: "data/test_war_url.bk"
config :clash_of_clans_slackbot, war_api: ClashOfClansSlackbot.Adapters.MockClashCallerAPI
config :clash_of_clans_slackbot, time_module: ClashOfClansSlackbot.Adapters.Calendar
