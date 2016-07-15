defmodule ClashOfClansSlackbot.Mixfile do
  use Mix.Project

  def project do
    [app: :clash_of_clans_slackbot,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: ClashOfClansSlackbot],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {ClashOfClansSlackbot, []},
      applications: [:logger, :slack, :httpotion, :poison, :websocket_client, :sqlitex, :edeliver, :exrm]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:slack, "~> 0.7.0"},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client"},
     {:httpotion, "~> 2.2.0"},
     {:mock, "~> 0.1.1", only: :test},
     {:sqlitex, "~> 1.0.0"},
     {:poison, "~> 2.0"},
     {:exrm, "~> 1.0.3"},
     {:edeliver, ">= 1.2.10"}]
  end
end
