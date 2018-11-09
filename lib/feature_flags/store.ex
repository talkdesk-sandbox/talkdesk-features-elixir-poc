defmodule FeatureFlags.Store do
  @table :feature_table

  def create() do
    :ets.new(@table, [:set, :named_table])
    :ok
  end

  def insert(key, content) do
    :ets.insert(@table, {key, content})
    :ok
  end

  def lookup(key) do
    case :ets.lookup(@table, key) do
      [] -> nil
      [{_, feature}] -> feature
    end
  end

  def whereis() do
    :ets.whereis(@table)
  end
end
