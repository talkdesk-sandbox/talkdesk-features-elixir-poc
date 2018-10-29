defmodule FeatureFlags do
  alias FeatureFlags.{Store, Flag, HTTP, HTTP.Response, HTTP.Error}

  @spec get(String.t(), list(), String.t()) :: Flag.t()
  def get(name, attrs \\ [], default \\ "off") do
    features = Store.lookup()

    feature =
      Enum.filter(features, fn entry -> feature_matches?(entry, name, attrs) end)
      |> Enum.at(0)

    if feature == nil do
      case get_from_server(name, attrs, default) do
        {:ok, status} ->
          %Flag{name: name, treatment: status}

        {:error, reason} ->
          {:error, reason}
      end
    else
      %Flag{name: name, treatment: elem(Map.fetch(feature, "defaultTreatment"), 1)}
    end
  end

  @spec is_alive(Flag.t()) :: boolean()
  def is_alive(flag) do
    flag.treatment == "on"
  end

  @spec get_from_server(String.t(), list(), String.t()) :: tuple()
  defp get_from_server(name, attrs, default) do
    with {:ok, %Response{body: body, status_code: 200}} <- HTTP.get(name),
         {:ok, decoded_body} <- HTTP.decode_body(body) do
      {:ok, get_treatment(decoded_body, attrs, default)}
    else
      {:ok, %Response{body: _body, status_code: _status}} -> {:ok, default}
      {:error, %Error{reason: reason}} -> {:error, reason}
      error -> error
    end
  end

  @spec feature_matches?(map(), String.t(), list()) :: boolean()
  defp feature_matches?(%{"name" => name}, name, attrs) when attrs == [], do: true

  defp feature_matches?(%{"name" => name} = entry, name, attrs) do
    check_attrs(entry, attrs)
  end

  defp feature_matches?(_, _, _), do: false

  @spec check_attrs(map(), list()) :: boolean()
  defp check_attrs(entry, attrs) do
    Enum.reduce_while(attrs, true, fn {k, v}, _ ->
      if Map.get(entry, k) == v do
        {:cont, true}
      else
        {:halt, false}
      end
    end)
  end

  @spec get_treatment(map(), list, String.t()) :: String.t()
  defp get_treatment(%{"defaultTreatment" => default_treatment} = feature, attrs, default) do
    if(check_attrs(feature, attrs)) do
      default_treatment
    else
      default
    end
  end
end
