defmodule Support.DummyApp do
  use GenServer

  def start_link(_) do
    :ignore
  end

  def init(args) do
    {:ok, args}
  end
end
