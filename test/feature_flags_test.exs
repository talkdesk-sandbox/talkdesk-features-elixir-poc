defmodule FeatureFlagsTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias FeatureFlags.Flag

  setup_all do
    :ets.new(:feature_table, [:set, :named_table, :public])
    :ok
  end

  test "check if a feature is alive" do
    feature = %Flag{name: "feature", treatment: "on"}

    assert FeatureFlags.is_alive(feature)
  end

  test "check if off feature is alive" do
    feature = %Flag{name: "off_feature", treatment: "off"}

    refute FeatureFlags.is_alive(feature)
  end

  test "getting feature" do
    use_cassette "get_feature" do
      feature =
        FeatureFlags.get("CENTRAL_backup_entries_to_s3", [{"killed", false}, {"rules", []}])

      assert feature == %Flag{name: "CENTRAL_backup_entries_to_s3", treatment: "on"}
    end
  end

  test "return default value for unexisting feature" do
    use_cassette "get_invalid" do
      feature = FeatureFlags.get("unexisting", [], "off")

      assert feature == %Flag{name: "unexisting", treatment: "off"}
    end
  end
end
