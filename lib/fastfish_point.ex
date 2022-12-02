defmodule Fastfish.Point do
  @moduledoc """
  A Point struct.
  """
  defstruct x: 0, y: 0, data: nil

  @spec make(number(), number(), any()) :: %__MODULE__{}
  def make(x, y, data), do: %__MODULE__{x: x, y: y, data: data}
end
