defmodule FeatureFlags.Supervisor do
  use Supervisor
  require Logger

  @app Confex.fetch_env!(:feature_flags, :app)

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children =
      case Confex.fetch_env!(:feature_flags, :active) do
        true ->
          [{@app, name: @app, strategy: :one_for_one}]

        false ->
          Logger.info("Feature flags fetching disabled, returning default values only")
          []
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
