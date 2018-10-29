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
    res = :ets.lookup(@table, key)

    if res == [] do
      nil
    else
      Enum.at(res, 0) |> elem(1)
    end
  end

  def whereis() do
    :ets.whereis(@table)
  end
end
