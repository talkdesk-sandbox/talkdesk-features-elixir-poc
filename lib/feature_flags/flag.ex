defmodule FeatureFlags.Flag do
  @type t :: %FeatureFlags.Flag{name: String.t(), treatment: String.t()}
  defstruct name: "default_flag", treatment: "off"
end
