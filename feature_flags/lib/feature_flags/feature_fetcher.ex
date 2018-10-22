defmodule FeatureFlags.FeatureFetcher do
  use GenServer
  require Logger

  @table :feature_table

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    :ets.new(@table, [:bag, :named_table])
    get_splits()
    schedule_fetch()
    {:ok, state}
  end

  def handle_info(:work, state) do
    get_splits()
    schedule_fetch()
    {:noreply, state}
  end

  defp get_splits() do
    url = "https://api.split.io/internal/api/v1/splits/environments/Staging"

    headers = [
      "Content-Type": "application/json",
      Authorization: "Bearer #{Application.fetch_env!(:feature_flags, :admin_key)}"
    ]

    options = [ssl: [{:versions, [:"tlsv1.2"]}]]

    response = HTTPoison.get(url, headers, options)

    case response do
      {:ok, %HTTPoison.Response{body: body, status_code: _status_code}} ->
        :ets.insert(
          @table,
          Jason.decode(body) |> elem(1) |> Map.fetch("objects")
        )

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(reason)
    end
  end

  defp schedule_fetch do
    Process.send_after(self(), :work, 60000)
  end
end
