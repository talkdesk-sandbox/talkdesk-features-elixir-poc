defmodule StoreTest do
  use ExUnit.Case

  alias FeatureFlags.Store

  setup do
    :ets.new(:feature_table, [:set, :named_table])
    :ok
  end

  test "#whereis check if table exists" do
    assert Store.whereis()
  end

  test "#insert checks if a feature is correclty inserted in the table" do
    Store.insert("myFeature", %{"treatment" => "on"})

    assert Store.lookup("myFeature") == %{"treatment" => "on"}
  end

  test "#lookup check if an existing feature is correclty retrieved" do
    feature = %{"treatment" => "off"}

    Store.insert("myFeature", feature)

    assert Store.lookup("myFeature") == feature
  end
end
