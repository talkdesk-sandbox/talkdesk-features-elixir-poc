defmodule Flag do
  defstruct name: "default_flag", treatment: "off"
end

defmodule FeatureFlags.API do
  def get(name, attrs \\ [], default \\ "off") do
    features = :ets.lookup(:feature_table, :ok) |> Keyword.get(:ok)

    feature =
      Enum.filter(features, fn entry -> feature_filter(entry, name, attrs) end)
      |> Enum.at(0)

    if feature == nil do
      treatment = get_from_server(name, attrs, default)
      %Flag{name: name, treatment: treatment}
    else
      %Flag{name: name, treatment: elem(Map.fetch(feature, "defaultTreatment"), 1)}
    end
  end

  def is_alive(flag) do
    flag.treatment == "on"
  end

  defp get_from_server(name, attrs, default) do
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
          :error -> get_treatment(Jason.decode(body) |> elem(1), attrs, default)
        end

      {:error, %HTTPoison.Error{reason: _reason}} ->
        default
    end
  end

  defp feature_filter(entry, name, attrs) when attrs == [] do
    Map.fetch(entry, "name") == {:ok, name}
  end

  defp feature_filter(entry, name, attrs) do
    Map.fetch(entry, "name") == {:ok, name} && check_attrs(entry, attrs)
  end

  defp check_attrs(entry, attrs) do
    Enum.reduce(attrs, true, fn attr, acc ->
      Map.fetch(entry, elem(attr, 0)) == {:ok, elem(attr, 1)} && acc
    end)
  end

  defp get_treatment(feature, attrs, default) do
    if(check_attrs(feature, attrs)) do
      elem(Map.fetch(feature, "defaultTreatment"), 1)
    else
      default
    end
  end
end
