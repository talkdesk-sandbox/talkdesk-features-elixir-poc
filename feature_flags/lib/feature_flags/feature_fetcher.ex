defmodule FeatureFlags.FeatureFetcher do
  use Task
  require Logger

  @table :feature_table

  def start_link(_arg) do
    Task.start_link(__MODULE__, :bootsrap, [])
  end

  def bootsrap do
    :ets.new(:feature_table, [:protected])
    get_splits()
    loop()
  end

  def loop() do
    receive do
    after
      60_000 ->
        get_splits()
        loop()
    end
  end

  defp get_splits() do
    url = "https://api.split.io/internal/api/v1/splits/environments/Staging"

    headers = [
      "Content-Type": "application/json",
      Authorization: "Bearer #{Application.fetch_env!(:feature_flags, :admin_key)}"
    ]

    response = HTTPoison.get(url, headers, [])

    case response do
      {:ok, %HTTPoison.Response{body: body, status_code: _status_code}} ->
        :ets.insert(@table, Jason.decode(body))

      {:error, %HTTPoison.Error{reason: reason}} -> Logger.error reason

    end
  end
end
