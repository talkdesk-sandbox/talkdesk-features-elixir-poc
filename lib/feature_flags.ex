defmodule FeatureFlags do
  alias FeatureFlags.{Store, Flag, HTTP, HTTP.Response, HTTP.Error}

  @spec get(String.t(), list(), String.t()) :: Flag.t() | {:error, term()}
  def get(name, attrs \\ [], default \\ "off") do
    case Confex.fetch_env!(:feature_flags, :active) do
      true -> get_feature(name, attrs, default)
      false -> %Flag{name: name, treatment: default}
    end
  end

  @spec is_enabled?(Flag.t()) :: boolean()
  def is_enabled?(flag) do
    flag.treatment == "on"
  end

  defp get_feature(name, attrs, default) do
    feature = Store.lookup(name)
    build_flag(feature, name, attrs, default)
  end

  defp build_flag(nil, name, attrs, default) do
    case get_from_server(name, attrs, default) do
      {:ok, status} ->
        %Flag{name: name, treatment: status}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_flag(feature, name, attrs, default) do
    if(check_attrs(feature, attrs)) do
      %Flag{name: name, treatment: Map.fetch(feature, "defaultTreatment") |> elem(1)}
    else
      %Flag{name: name, treatment: default}
    end
  end

  defp get_from_server(name, attrs, default) do
    with {:ok, %Response{body: body, status_code: 200}} <- HTTP.get(name) do
      {:ok, get_treatment(body, attrs, default)}
    else
      {:ok, %Response{body: _body, status_code: _status}} -> {:ok, default}
      {:error, %Error{reason: reason}} -> {:error, reason}
      error -> error
    end
  end

  defp check_attrs(entry, attrs) do
    Enum.reduce_while(attrs, true, fn {k, v}, _ ->
      if Map.get(entry, k) == v do
        {:cont, true}
      else
        {:halt, false}
      end
    end)
  end

  defp get_treatment(%{"defaultTreatment" => default_treatment} = feature, attrs, default) do
    if(check_attrs(feature, attrs)) do
      default_treatment
    else
      default
    end
  end
end
