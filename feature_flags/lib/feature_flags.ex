defmodule Flag do
  defstruct name: "default_flag", treatment: "off"
end

defmodule FeatureFlags do
  @moduledoc """
  Documentation for FeatureFlags.
  """
  def get(name, default \\ "off") do
    features = :ets.lookup(:feature_table, :ok) |> Keyword.get(:ok)

    feature =
      Enum.filter(features, fn entry -> Map.fetch(entry, "name") == {:ok, name} end)
      |> Enum.at(0)

    if feature == nil do
      treatment = get_from_server(name, default)
      %Flag{name: name, treatment: treatment}
    else
      %Flag{name: name, treatment: elem(Map.fetch(feature, "defaultTreatment"), 1)}
    end
  end

  def is_alive(flag) do
    flag.treatment == "on"
  end

  defp get_from_server(name, default) do
    url = "https://api.split.io/internal/api/v1/splits/#{name}/environments/Staging"

    headers = [
      "Content-Type": "application/json",
      Authorization: "Bearer #{Application.fetch_env!(:feature_flags, :admin_key)}"
    ]

    options = [ssl: [{:versions, [:"tlsv1.2"]}]]

    response = HTTPoison.get(url, headers, options)

    case response do
      {:ok, %HTTPoison.Response{body: body, status_code: _status_code}} ->
        case Jason.decode(body) |> elem(1) |> Map.fetch("code") do
          {:ok, _} -> default
          :error -> Jason.decode(body) |> elem(1) |> Map.fetch("defaultTreatment") |> elem(1)
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        default
    end
  end
end
