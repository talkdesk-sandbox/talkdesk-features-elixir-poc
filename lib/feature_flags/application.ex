defmodule FeatureFlags.Application do
  use Application

  def start(_type, _args) do
    FeatureFlags.Supervisor.start_link(name: FeatureFlags.Supervisor)
  end
end
