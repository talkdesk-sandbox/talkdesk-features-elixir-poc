defmodule FeatureFlags.MixProject do
  use Mix.Project

  def project do
    [
      app: :feature_flags,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {FeatureFlags.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.4"},
      {:exvcr, "~> 0.10", only: :test},
      {:confex, "~> 3.3.1"}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
