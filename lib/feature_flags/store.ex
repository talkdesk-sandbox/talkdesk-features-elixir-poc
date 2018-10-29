defmodule FeatureFlags.Store do
  @table :feature_table

  def create() do
    :ets.new(@table, [:bag, :named_table])
    :ok
  end

  def insert(content) do
    :ets.insert(@table, content)
    :ok
  end

  def lookup() do
    :ets.lookup(@table, :features) |> Keyword.get(:features)
  end

  def whereis() do
    :ets.whereis(@table)
  end
end
