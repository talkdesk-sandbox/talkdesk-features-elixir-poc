defmodule FeatureFlags.HTTP.Behaviour do
  alias FeatureFlags.HTTP.{Response, Error}

  @callback get(String.t()) :: {:ok, %Response{}} | {:error, %Error{}}
  @callback get() :: {:ok, %Response{}} | {:error, %Error{}}
end
