defmodule FeatureFlags do
  @moduledoc """
  Documentation for FeatureFlags.
  """

  def get(name, account_id, default \\ "off") do
    features =
      :ets.lookup(:feature_table, :ok)
      |> Enum.at(0)
      |> elem(1)
      |> Map.fetch("objects")
      |> elem(1)

    feature =
      Enum.filter(features, fn entry -> Map.fetch(entry, "name") == {:ok, name} end)
      |> Enum.at(0)

    if feature == nil do
      default
    else
      Map.fetch(feature, "defaultTreatment")
    end
  end
end
