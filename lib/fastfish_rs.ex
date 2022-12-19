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

  def sample_multiradii(items, distance, sample) do
    Fastfish.Rsnif.sample_multiradii(items, distance, sample)
  end

  def demo_multiradii do
    items = 0..500 |> Enum.map(fn _ ->
      :rand.uniform() * 5.0 + 7.0
    end)
    sample_multiradii(items, 10.0, 30)
  end
end
