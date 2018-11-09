defmodule FeatureFlags.FeatureFetcher do
  use GenServer
  require Logger

  alias FeatureFlags.{Store, HTTP, HTTP.Response, HTTP.Error}

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(state) do
    Store.create()
    send(self(), :work)
    {:ok, state}
  end

  def handle_info(:work, state) do
    with {:ok, period} <- update_cache() do
      schedule_fetch(period)
    else
      {:error, reason} ->
        Logger.error(reason)

        Confex.fetch_env!(:feature_flags, :period) |> schedule_fetch()
    end

    {:noreply, state}
  end

  defp update_cache() do
    with {:ok, %Response{body: body, status_code: 200}} <- HTTP.get(),
         {:ok, features} <- get_features(body),
         _ <- store_features(features) do
      {:ok, Confex.fetch_env!(:feature_flags, :period)}
    else
      {:ok, %Response{body: body, status_code: 429}} -> handle_rate_limit(body)
      {:error, %Error{reason: reason}} -> {:error, reason}
      error -> error
    end
  end

  defp store_features(features) do
    Enum.each(features, fn %{"name" => name} = feature ->
      Store.insert(name, feature)
    end)
  end

  defp get_features(decoded_body) do
    Map.fetch(decoded_body, "objects")
  end

  defp get_rate_limit(decoded_body) do
    Map.fetch(decoded_body, "X-RateLimit-Reset-Seconds-Org")
  end

  defp handle_rate_limit(body) do
    with {:ok, rate_limit} <- get_rate_limit(body) do
      {:ok, rate_limit * 1000}
    else
      {:error, reason} -> {:error, reason}
      :error -> {:error, :rate_limit}
    end
  end

  defp schedule_fetch(period) do
    Process.send_after(self(), :work, period)
  end
end
