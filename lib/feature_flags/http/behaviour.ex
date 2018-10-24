defmodule FeatureFlags.HTTP.Behaviour do
  @callback get(String.t()) :: tuple()
  @callback get() :: tuple()
end
