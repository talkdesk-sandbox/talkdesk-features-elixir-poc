defmodule FeatureFlags.Store do
  @table :feature_table

  def create() do
    :ets.new(@table, [:bag, :named_table])
  end

  def insert(content) do
    :ets.insert(@table, content)
  end

  def lookup() do
    :ets.lookup(@table, :ok)
  end

  def whereis() do
    :ets.whereis(@table)
  end
end
