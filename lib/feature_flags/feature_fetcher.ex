defmodule FeatureFlags.FeatureFetcher do
  use GenServer
  require Logger

  alias FeatureFlags.{Store, HTTP, HTTP.Response, HTTP.Error}

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(state) do
    Store.create()

    with {:ok, period} <- get_splits() do
      schedule_fetch(period)
    else
      {:error, reason} ->
        Logger.error(reason)

        Application.fetch_env!(:feature_flags, :period) |> schedule_fetch()
    end

    {:ok, state}
  end

  def handle_info(:work, state) do
    with {:ok, period} <- get_splits() do
      schedule_fetch(period)
    else
      {:error, reason} ->
        Logger.error(reason)

        Application.fetch_env!(:feature_flags, :period) |> schedule_fetch()
    end

    {:noreply, state}
  end

  defp get_splits() do
    with {:ok, %Response{body: body, status_code: 200}} <- HTTP.get(),
         {:ok, decoded_body} <- HTTP.decode_body(body),
         {:ok, features} <- get_features(decoded_body),
         :ok <- Store.insert({:features, features}) do
      {:ok, Application.fetch_env!(:feature_flags, :period)}
    else
      {:ok, %Response{body: body, status_code: 429}} -> handle_rate_limit(body)
      {:error, %Error{reason: reason}} -> {:error, reason}
      error -> error
    end
  end

  defp get_features(decoded_body) do
    Map.fetch(decoded_body, "objects")
  end

  defp get_rate_limit(decoded_body) do
    Map.fetch(decoded_body, "X-RateLimit-Reset-Seconds-Org")
  end

  defp handle_rate_limit(body) do
    with {:ok, decoded_body} <- HTTP.decode_body(body),
         {:ok, rate_limit} <- get_rate_limit(decoded_body) do
      {:ok, rate_limit * 1000}
    else
      {:error, _} -> {:error, :rate_limit}
    end
  end

  defp schedule_fetch(period) do
    Process.send_after(self(), :work, period)
  end
end
