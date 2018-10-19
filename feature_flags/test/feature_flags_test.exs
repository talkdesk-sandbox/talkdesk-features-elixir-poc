defmodule FeatureFlagsTest do
  use ExUnit.Case
  doctest FeatureFlags

  test "check if bootsrap was successful" do
    assert :ets.whereis(:feature_table) != :undefined
  end

end
