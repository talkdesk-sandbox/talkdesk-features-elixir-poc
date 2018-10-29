defmodule FeatureFlags do
  alias FeatureFlags.{Store, Flag, HTTP, HTTP.Response, HTTP.Error}

  @spec get(String.t(), list(), String.t()) :: Flag.t() | {:error, term()}
  def get(name, attrs \\ [], default \\ "off") do
    feature = Store.lookup(name)

    if feature == nil do
      case get_from_server(name, attrs, default) do
        {:ok, status} ->
          %Flag{name: name, treatment: status}

        {:error, reason} ->
          {:error, reason}
      end
    else
      if(check_attrs(feature, attrs)) do
        %Flag{name: name, treatment: Map.fetch(feature, "defaultTreatment") |> elem(1)}
      else
        %Flag{name: name, treatment: default}
      end
    end
  end

  @spec is_alive(Flag.t()) :: boolean()
  def is_alive(flag) do
    flag.treatment == "on"
  end

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
