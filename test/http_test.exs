defmodule HTTPTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias FeatureFlags.{HTTP, HTTP.Response}

  test "#get/0 performs an HTTP request to get all features" do
    use_cassette "http_get" do
      response = HTTP.get()

      assert {:ok, %Response{body: body, status_code: 200}} = response
    end
  end

  test "#get/1 performs an HTTP request to get the feature with the given name" do
    use_cassette "http_get_name" do
      response = HTTP.get("CXM_prototype_runtime")

      assert {:ok, %Response{body: body, status_code: 200}} = response
    end
  end

  test "#get/1 performs an HTTP request with an invalid name" do
    use_cassette "http_get_invalid" do
      response = HTTP.get("invalid")

      assert {:ok, %Response{body: body, status_code: 404}} = response
    end
  end
end
