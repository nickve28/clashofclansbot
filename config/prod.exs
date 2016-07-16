use Mix.Config

config :clash_of_clans_slackbot, token: System.get_env("SLACK_TOKEN")
config :clash_of_clans_slackbot, database: System.get_env("DBNAME")
config :clash_of_clans_slackbot, clashapi_token: System.get_env("CLASHAPI_TOKEN")
