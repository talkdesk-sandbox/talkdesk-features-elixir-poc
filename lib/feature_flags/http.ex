defmodule FeatureFlags.HTTP do
  @behaviour FeatureFlags.HTTP.Behaviour

  alias FeatureFlags.HTTP.Response
  alias FeatureFlags.HTTP.Error

  @test_url Application.fetch_env!(:feature_flags, :base_url)
  @base_url "https://api.split.io/internal/api/v1/splits/"
  @headers [
    "Content-Type": "application/json",
    Authorization: "Bearer #{Application.fetch_env!(:feature_flags, :admin_key)}"
  ]
  @options [ssl: [{:versions, [:"tlsv1.2"]}]]

  def get(name) do
    url =
      @test_url <>
        name <> "/environments/" <> Application.fetch_env!(:feature_flags, :environment)

    response = HTTPoison.get(url, @headers, @options)

    case response do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code}} ->
        {:ok, %Response{body: body, status_code: status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %Error{reason: reason}}
    end
  end

  def get() do
    url = @base_url <> "environments/" <> Application.fetch_env!(:feature_flags, :environment)
    response = HTTPoison.get(url, @headers, @options)

    case response do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code}} ->
        {:ok, %Response{body: body, status_code: status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %Error{reason: reason}}
    end
  end
end
