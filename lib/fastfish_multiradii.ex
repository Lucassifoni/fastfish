defmodule FastfishMultiradii do
  @moduledoc """
  An implementation with multiple radii
  """
  alias FastfishCircle, as: Circle

  def demo() do
    list = 0..200 |> Enum.map(fn _ -> if (:rand.uniform() < 0.17), do: 30, else: 10 end)
    place(list, 5)
  end
  def random_angle, do: :rand.uniform() * :math.pi() * 2
  def random_coords_around(%Circle{} = c, r2, d) do
    a = random_angle()
    p = d * 2 + c.r + r2
    {
      c.x + p * :math.cos(a),
      c.y + p * :math.sin(a)
    }
  end

  def intersects?(%Circle{} = a, %Circle{} = b, d) do
    dx = b.x - a.x
    dy = b.y - a.y
    d = b.r + a.r + d
    (dx * dx + dy * dy) <= (d * d)
  end

  def intersects_any?(circles, %Circle{} = c, d) do
    Enum.any?(circles, fn c1 -> intersects?(c1, c, d) end)
  end

  def suspect_circles(circles, %Circle{} = c, r2, d) do
    virtual_circle = %Circle{
      x: c.x,
      y: c.y,
      r: d * 2 + r2 * 2 + c.r
    }
    Enum.filter(circles, fn c1 ->
      intersects?(c1, virtual_circle, d)
    end)
  end

  def place(radii_list, distance) do
    [h|t] = radii_list |> Enum.shuffle
    first = %Circle{x: 0, y: 0, r: h}
    place(t, [first], [first], first, distance)
  end
  def place([], _active_list, all_circles, _, _), do: all_circles
  def place(_radii_list, [], all_circles, _, _), do: all_circles
  def place([new_r | rest], [ah | at], all_circles, current_circle, distance) do
    suspects = suspect_circles(all_circles, current_circle, new_r, distance)
    case get_new_circle(current_circle, new_r, suspects, distance) do
      {:ok, %Circle{} = c} ->
        place(rest, [c | [ah | Enum.shuffle(at)]], [c | all_circles], current_circle, distance)
      {:error, _} ->
        place([new_r | rest], Enum.shuffle(at), all_circles, ah, distance)
    end
  end

  def get_new_circle(%Circle{} = c, r, susp, d) do
    get_new_circle(%Circle{} = c, r, susp, d, 6)
  end
  def get_new_circle(_c, _r, _all, _d, 0) do
    {:error, "Failed to place a new circle around current"}
  end
  def get_new_circle(%Circle{} = c, r, susp, d, k) do
    {x, y} = random_coords_around(c, r, d)
    pending = %Circle{x: x, y: y, r: r}
    if intersects_any?(susp, pending, d) do
      get_new_circle(%Circle{} = c, r, susp, d, k - 1)
    else
      {:ok, pending}
    end
  end

end
