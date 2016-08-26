use Mix.Config

config :clash_of_clans_slackbot, token: System.get_env("SLACK_TOKEN")
config :clash_of_clans_slackbot, database: System.get_env("DBNAME")
config :clash_of_clans_slackbot, clashapi_token: System.get_env("CLASHAPI_TOKEN")
config :clash_of_clans_slackbot, clantag: System.get_env("CLASHAPI_CLANTAG")

config :logger,
  backends: [
    {LoggerFileBackend, :error_log},
    {LoggerFileBackend, :info_log}
  ]

config :logger, :info_log,
  path: "/logs/clash_out.log",
  level: :info

config :logger, :error_log,
  path: "/logs/clash_err.log",
  level: :error

