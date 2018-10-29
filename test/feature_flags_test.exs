defmodule FeatureFlagsTest do
  use ExUnit.Case

  alias FeatureFlags.Store
  alias FeatureFlags.Flag

  setup do
    bypass = Bypass.open(port: 8080)
    {:ok, bypass: bypass}
  end

  test "check if bootsrap was successful" do
    assert Store.whereis() != :undefined
  end

  test "getting feature from cache" do
    feature = FeatureFlags.get("CENTRAL_backup_entries_to_s3", [{"killed", false}, {"rules", []}])

    assert feature == %Flag{name: "CENTRAL_backup_entries_to_s3", treatment: "on"}
  end

  test "return default value for unexisting feature", %{
    bypass: bypass
  } do
    Bypass.expect_once(
      bypass,
      fn conn ->
        Plug.Conn.resp(conn, 404, "")
      end
    )

    feature = FeatureFlags.get("unexisting", [], "off")

    assert feature == %Flag{name: "unexisting", treatment: "off"}
  end

  test "get feature from server when cache misses", %{
    bypass: bypass
  } do
    Bypass.expect_once(
      bypass,
      fn conn ->
        Plug.Conn.resp(conn, 200, ~s<{"name":"missingFeature","defaultTreatment":"on"}>)
      end
    )

    feature = FeatureFlags.get("missingFeature", [])

    assert feature == %Flag{name: "missingFeature", treatment: "on"}
  end

  test "rate limitting", %{
    bypass: bypass
  } do
    Bypass.expect_once(
      bypass,
      fn conn ->
        Plug.Conn.resp(conn, 429, ~s<{"X-RateLimit-Reset-Seconds-Org":5}>)
      end
    )

    feature = FeatureFlags.get("someFeature", [])

    assert feature == %Flag{name: "someFeature", treatment: "off"}
  end

  test "check if a feature is alive" do
    feature = %Flag{name: "feature", treatment: "on"}

    assert FeatureFlags.is_alive(feature)
  end

  test "check if off feature is alive" do
    feature = %Flag{name: "off_feature", treatment: "off"}

    refute FeatureFlags.is_alive(feature)
  end
end
