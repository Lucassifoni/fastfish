defmodule FastfishRS do
  def sample(w, h, d, k, p),
    do:
      Fastfish.Rsnif.sample(w, h, d, k, p)
      |> Enum.map(fn {x, y} ->
        %Fastfish.Point{
          x: x,
          y: y
        }
      end)
end
