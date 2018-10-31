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

    with {:ok, %HTTPoison.Response{body: body, status_code: status_code}} <-
           HTTPoison.get(url, @headers, @options),
         {:ok, decoded_body} <- Jason.decode(body) do
      {:ok, %Response{body: decoded_body, status_code: status_code}}
    else
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %Error{reason: reason}}

      {:error, %Jason.DecodeError{}} ->
        {:error, :body_decode}
    end
  end

  def get() do
    url = @base_url <> "environments/" <> Confex.fetch_env!(:feature_flags, :environment)

    with {:ok, %HTTPoison.Response{body: body, status_code: status_code}} <-
           HTTPoison.get(url, @headers, @options),
         {:ok, decoded_body} <- Jason.decode(body) do
      {:ok, %Response{body: decoded_body, status_code: status_code}}
    else
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %Error{reason: reason}}

      {:error, %Jason.DecodeError{}} ->
        {:error, :body_decode}
    end
  end
end
