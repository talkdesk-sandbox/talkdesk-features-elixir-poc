defmodule HTTPTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias FeatureFlags.{HTTP, HTTP.Response}

  test "HTTP get" do
    use_cassette "http_get" do
      response = HTTP.get()

      assert {:ok, %Response{body: body, status_code: 200}} = response
    end
  end

  test "HTTP get name" do
    use_cassette "http_get_name" do
      response = HTTP.get("CXM_prototype_runtime")

      assert {:ok, %Response{body: body, status_code: 200}} = response
    end
  end

  test "HTTP get invalid" do
    use_cassette "http_get_invalid" do
      response = HTTP.get("invalid")

      assert {:ok, %Response{body: body, status_code: 404}} = response
    end
  end

  test "HTTP decode" do
    decoded =
      HTTP.decode_body(
        "{\"objects\":[{\"name\": \"CXM_prototype_runtime\", \"defaultTreatment\": \"on\"}]}"
      )

    expected =
      {:ok, %{"objects" => [%{"defaultTreatment" => "on", "name" => "CXM_prototype_runtime"}]}}

    assert expected == decoded
  end
end
