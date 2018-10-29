defmodule FeatureFlags.MixProject do
  use Mix.Project

  def project do
    [
      app: :feature_flags,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
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
      {:httpoison, "~> 1.0"},
      {:bypass, "~> 0.9", only: :test},
      {:plug_cowboy, "~>1.0"},
      {:confex, "~> 3.3.1"}
    ]
  end
end
