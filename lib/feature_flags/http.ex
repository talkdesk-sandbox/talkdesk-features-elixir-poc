defmodule FeatureFlags.HTTP do
  @behaviour FeatureFlags.HTTP.Behaviour

  alias FeatureFlags.{HTTP.Response, HTTP.Error}

  @base_url "https://api.split.io/internal/api/v1/splits/"

  @headers [
    "Content-Type": "application/json",
    Authorization: "Bearer #{Confex.fetch_env!(:feature_flags, :api_key)}"
  ]
  @options [ssl: [{:versions, [:"tlsv1.2"]}]]

  def get(name) do
    url = @base_url <> name <> "/environments/" <> Confex.fetch_env!(:feature_flags, :environment)

    with true <- Confex.fetch_env!(:feature_flags, :active),
         {:ok, %HTTPoison.Response{body: body, status_code: status_code}} <-
           HTTPoison.get(url, @headers, @options) do
      {:ok, %Response{body: body, status_code: status_code}}
    else
      false ->
        {:ok, %Response{body: "", status_code: 404}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %Error{reason: reason}}
    end
  end

  def get() do
    url = @base_url <> "environments/" <> Confex.fetch_env!(:feature_flags, :environment)

    case HTTPoison.get(url, @headers, @options) do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code}} ->
        {:ok, %Response{body: body, status_code: status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %Error{reason: reason}}
    end
  end

  def decode_body(body) do
    case Jason.decode(body) do
      {:ok, decoded_body} -> {:ok, decoded_body}
      {:error, _} -> {:error, :body_decode}
    end
  end
end
