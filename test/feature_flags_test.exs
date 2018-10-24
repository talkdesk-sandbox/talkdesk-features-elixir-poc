defmodule FeatureFlagsTest do
  use ExUnit.Case
  doctest FeatureFlags

  alias FeatureFlags.Store
  alias FeatureFlags.Flag
  alias FeatureFlags.FeatureAPI, as: API

  test "check if bootsrap was successful" do
    assert Store.whereis() != :undefined
  end

  test "getting feature from cache" do
    feature = API.get("CXM_prototype_runtime", [{"killed", false}, {"rules", []}])

    assert feature == %Flag{name: "CXM_prototype_runtime", treatment: "on"}
  end

  test "return default value for unexisting feature" do
    feature = API.get("unexisting", [], "off")

    assert feature == %Flag{name: "unexisting", treatment: "off"}
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
