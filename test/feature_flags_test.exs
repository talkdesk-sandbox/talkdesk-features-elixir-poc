defmodule FeatureFlagsTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias FeatureFlags.Flag

  setup_all do
    :ets.new(:feature_table, [:set, :named_table, :public])
    :ok
  end

  test "#is_alive check if a feature is alive" do
    feature = %Flag{name: "feature", treatment: "on"}

    assert FeatureFlags.is_alive(feature)
  end

  test "#is_alive check if off feature is alive" do
    feature = %Flag{name: "off_feature", treatment: "off"}

    refute FeatureFlags.is_alive(feature)
  end

  test "#get performs a request to get the treatment of a given feature" do
    use_cassette "get_feature" do
      feature =
        FeatureFlags.get("CENTRAL_backup_entries_to_s3", [{"killed", false}, {"rules", []}])

      assert feature == %Flag{name: "CENTRAL_backup_entries_to_s3", treatment: "on"}
    end
  end

  test "#get performs a request for an unexisting feature and returns the default value" do
    use_cassette "get_invalid" do
      feature = FeatureFlags.get("unexisting", [], "off")

      assert feature == %Flag{name: "unexisting", treatment: "off"}
    end
  end
end
