use Mix.Config

config :clash_of_clans_slackbot, token: "sometoken"
config :clash_of_clans_slackbot, database: "dev.sqlite3"
config :clash_of_clans_slackbot, clashapi_token: "sometoken"
config :clash_of_clans_slackbot, post_channel: "bottesting"
config :clash_of_clans_slackbot, war_url_filename: "data/dev_war_url.bk"
config :clash_of_clans_slackbot, clantag: "#C8000C0"

config :logger,
  backends: [
    {LoggerFileBackend, :error_log},
    {LoggerFileBackend, :info_log}
  ]

config :logger, :info_log,
  path: "./logs/clash_out.log",
  level: :info

config :logger, :error_log,
  path: "./logs/clash_err.log",
  level: :error

