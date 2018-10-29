defmodule FeatureFlags.Application do
  use Application

  def start(_type, _args) do
    Confex.resolve_env!(:feature_flags)
    FeatureFlags.Supervisor.start_link(name: FeatureFlags.Supervisor)
  end
end
