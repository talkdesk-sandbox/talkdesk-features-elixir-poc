defmodule FeatureFlags.FeatureAPI do
  alias FeatureFlags.Store
  alias FeatureFlags.Flag
  alias FeatureFlags.HTTP
  alias FeatureFlags.HTTP.Response

  def get(name, attrs \\ [], default \\ "off") do
    features = Store.lookup() |> Keyword.get(:ok)

    feature =
      Enum.filter(features, fn entry -> feature_filter(entry, name, attrs) end)
      |> Enum.at(0)

    if feature == nil do
      treatment = get_from_server(name, attrs, default)

      case treatment do
        {:ok, status} ->
          %Flag{name: name, treatment: status}

        {:wait, time} ->
          :timer.sleep(time * 1000)
          get(name, attrs, default)
      end
    else
      %Flag{name: name, treatment: elem(Map.fetch(feature, "defaultTreatment"), 1)}
    end
  end

  def is_alive(flag) do
    flag.treatment == "on"
  end

  defp get_from_server(name, attrs, default) do
    response = HTTP.get(name)

    with {:ok, %Response{body: body, status_code: status_code}} <- response,
         200 <- status_code do
      {:ok, get_treatment(Jason.decode(body) |> elem(1), attrs, default)}
    else
      429 ->
        {:wait,
         Jason.decode(response |> elem(1) |> Map.fetch(:body) |> elem(1))
         |> elem(1)
         |> Map.fetch("X-RateLimit-Reset-Seconds-Org")
         |> elem(1)}

      404 ->
        {:ok, default}

      {:error, _} ->
        {:ok, default}
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
