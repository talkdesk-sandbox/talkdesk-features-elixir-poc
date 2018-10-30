defmodule FeatureFlags.Supervisor do
  use Supervisor

  @app Confex.fetch_env!(:feature_flags, :app)

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {@app, name: @app, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
