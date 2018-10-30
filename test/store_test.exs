defmodule StoreTest do
  use ExUnit.Case, async: true

  alias FeatureFlags.Store

  test "Store table creation" do
    exists = Store.whereis()

    assert exists
  end

  setup do
    :ets.new(:feature_table, [:set, :named_table])
    :ok
  end

  test "Store insert and lookup" do
    Store.insert("myFeature", %{"treatment" => "on"})

    stored_value = Store.lookup("myFeature")

    assert stored_value == %{"treatment" => "on"}
  end
end
