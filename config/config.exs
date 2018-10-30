use Mix.Config

config :feature_flags,
  api_key: {:system, "SPLIT_IO_API_KEY", "localhost"},
  period: {:system, "SPLIT_PERIOD", 60000},
  environment: {:system, "SPLIT_ENV"}

if Mix.env() == :test do
  config :feature_flags, :app, Support.DummyApp
  config :exvcr, filter_request_headers: ["Authorization"]
else
  config :feature_flags, :app, FeatureFlags.FeatureFetcher
end
