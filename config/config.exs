use Mix.Config

config :feature_flags,
  api_key: {:system, "SPLIT_IO_API_KEY", "localhost"},
  period: {:system, "SPLIT_PERIOD", 60000},
  environment: {:system, "SPLIT_ENV"}

if Mix.env() == :test do
  config :feature_flags, :base_url, "http://localhost:8080/"
else
  config :feature_flags, :base_url, "https://api.split.io/internal/api/v1/splits/"
end
