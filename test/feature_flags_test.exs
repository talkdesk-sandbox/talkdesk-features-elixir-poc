defmodule FeatureFlagsTest do
  use ExUnit.Case
  doctest FeatureFlags

  alias FeatureFlags.Store
  alias FeatureFlags.Flag
  alias FeatureFlags.FeatureAPI, as: API

  setup do
    bypass = Bypass.open(port: 8080)

    :ets.new(:counter, [:named_table, :public])

    {:ok, bypass: bypass}
  end

  test "check if bootsrap was successful" do
    assert Store.whereis() != :undefined
  end

  test "getting feature from cache" do
    feature = API.get("CENTRAL_backup_entries_to_s3", [{"killed", false}, {"rules", []}])

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

    feature = API.get("unexisting", [], "off")

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

    feature = API.get("missingFeature", [])

    assert feature == %Flag{name: "missingFeature", treatment: "on"}
  end

  test "rate limitting", %{
    bypass: bypass
  } do
    Bypass.expect(
      bypass,
      fn conn ->
        case :ets.lookup(:counter, :count) do
          [] ->
            :ets.update_counter(:counter, :count, {2, 1}, {:count, 0})
            Plug.Conn.resp(conn, 429, ~s<{"X-RateLimit-Reset-Seconds-Org":30}>)

          [count: 1] ->
            Plug.Conn.resp(conn, 200, ~s<{"name":"someFeature","defaultTreatment":"on"}>)
        end
      end
    )

    feature = API.get("someFeature", [])

    assert feature == %Flag{name: "someFeature", treatment: "on"}
  end

  test "check if a feature is alive" do
    feature = %Flag{name: "feature", treatment: "on"}

    assert API.is_alive(feature)
  end

  test "check if off feature is alive" do
    feature = %Flag{name: "off_feature", treatment: "off"}

    assert !API.is_alive(feature)
  end
end
