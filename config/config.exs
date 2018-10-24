use Mix.Config

config :feature_flags, :admin_key, System.get_env("SPLIT_ADMIN_KEY")
config :feature_flags, :period, System.get_env("SPLIT_PERIOD") || 60000
config :feature_flags, :environment, System.get_env("SPLIT_ENV") || "Staging"
