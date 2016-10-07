# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :clash_of_clans_slackbot, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:clash_of_clans_slackbot, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
config :clash_of_clans_slackbot, post_channel: "clashofclans"

config :quantum, cron: [
 "0 */12 * * *":      {Tasks.FindBadDonators, :run},
 "45 * * * *":       {Tasks.PollClashApi, :run}
]

config :clash_of_clans_slackbot, war_api: ClashOfClansSlackbot.Adapters.ClashCallerAPI
config :clash_of_clans_slackbot, time_module: :calendar

config :clash_of_clans_slackbot, donation_treshold: 0.66
config :clash_of_clans_slackbot, min_donations: 500
config :clash_of_clans_slackbot, player_links: %{
  "Nickadin" => "Nick",
  "Hit" => "Nick",
  "[C]rAnCkEt~" => "Thunder ⚡⚡",
  "Zoyvod" => "zoy",
  "AceMichael" => "zoy",
  "krill 2.0" => "juke",
  "Nobody" => "Drew",
  "Lock N Load" => "bullybound"
}


import_config "#{Mix.env}.exs"

