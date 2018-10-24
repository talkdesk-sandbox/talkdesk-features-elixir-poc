defmodule FeatureFlags.FeatureFetcher do
  use GenServer
  require Logger

  alias FeatureFlags.Store
  alias FeatureFlags.HTTP
  alias FeatureFlags.HTTP.Response
  alias FeatureFlags.HTTP.Error

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Store.create()

    with {:ok, period} <- get_splits() do
      schedule_fetch(period)
      {:ok, state}
    else
      {:error, reason} -> Logger.error(reason)
    end
  end

  def handle_info(:work, state) do
    with {:ok, period} <- get_splits() do
      schedule_fetch(period)
      {:noreply, state}
    else
      {:error, reason} -> Logger.error(reason)
    end
  end

  defp get_splits() do
    response = HTTP.get()

    case response do
      {:ok, %Response{body: body, status_code: _status_code}} ->
        Store.insert(Jason.decode(body) |> elem(1) |> Map.fetch("objects"))
        {:ok, Application.fetch_env!(:feature_flags, :period)}

      {:error, %Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp schedule_fetch(period) do
    Process.send_after(self(), :work, period)
  end
end
