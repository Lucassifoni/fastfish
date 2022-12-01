defmodule Fastfish.Point do
  @moduledoc """
  A Point struct.
  """
  defstruct x: 0, y: 0, data: nil

  @spec make(number(), number(), any()) :: %__MODULE__{}
  def make(x, y, data), do: %__MODULE__{x: x, y: y, data: data}
end

defmodule Fastfish do
  @moduledoc """
  Implementation of a 2D version of "Fast Poisson Disk Sampling in Arbitrary Dimensions" by Robert Bridson
  """

  @doc """
  Quoting Robert Bridson : "The algorithm takes as input the extent of the
  sample domain in R^n, the minimum distance r between samples, and a constant
  k as the limit of samples to choose before rejection n the algorithm
  (typically k = 30).
  We'll work in 2D only. My other addition is that I need at least M positions
  output by the algorithm since I want to place M elements on a grid.
  Comments are the paper itself, quoted before their implementation
  """
  @spec sample(number(), number(), number(), number(), list()) ::
          {:ok, list(Fastfish.Point)} | {:error, String.t()}
  def sample(domain_width, domain_height, distance, k_samples, items) do
    num_items = length(items)

    # Step 0 : Initialize a n-dimensional grid for storing samples and accelerating spatial searches
    # Here N = 2
    # We can't use a List since we'd like O(1) random access at best, but certainly not O(n)
    # For a first implementation, I'll initialize a map with lines & columns
    # The value -1 represents the absence of sample.
    line_cells =
      Enum.reduce(Range.new(0, domain_width), %{}, fn i, out -> Map.put(out, i, -1) end)

    grid =
      Enum.reduce(Range.new(0, domain_height), %{}, fn i, lines ->
        Map.put(lines, i, line_cells)
      end)

    # We pick the cell size to be bound by r / sqrt(n) so that each grid cell will contain
    # at most one sample
    cell_size = distance / :math.sqrt(2)

    # Step 1 : Select the initial sample, x0, randomly chosen from the domain.
    # Insert it into the background grid (implicit: at center) and initialize an "active list"
    # (an array of sample indices) with this index (zero)
    [x0 | rest] = Enum.shuffle(items)
    {grid, item} = insert_point(grid, domain_width / 2 - distance / 2, domain_height / 2 - distance / 2, x0)
    active_list = [item]

    # Step 2 : while the active list is not empty (and while we have elements to place)
    placed_items =
      place_elems(
        grid,
        rest,
        active_list,
        k_samples,
        [item],
        cell_size,
        distance,
        {domain_width, domain_height}
      )

    f_length = length(placed_items)

    if f_length == num_items do
      {:ok, placed_items}
    else
      {:error,
       "Failed to place #{num_items} on #{domain_width}x#{domain_height} domain with k=#{k_samples}, placed only #{f_length} items"}
    end
  end

  @doc """
  Let's handle this "while" paragraph with recursion and set base conditions.
  """
  def place_elems(_grid, [], _active_list, _k_samples, placed_items, _cell_size, _radius, _),
    do: placed_items

  def place_elems(_grid, _items, [], _k_samples, placed_items, _cell_size, _radius, _),
    do: placed_items

  def place_elems(grid, items, active_list, k_samples, placed_items, cell_size, radius, bounds) do
    # Choose a random index from the active list (say i)
    [i | rest] = Enum.shuffle(active_list)

    # Generate up to k points chosen uniformly from the spherical annulus between radius r and 2r around xi
    # For each point, check if it is whithin distance r of existing samples (using the grid to only test nearby samples)
    case generate_point(grid, i, k_samples, radius, bounds) do
      # If a point is adequately far from existing samples, emit it as the next sample (place it in the grid)
      # and add it to the active list
      {:ok, {x, y}} ->
        [item | rest_items] = items
        {u_grid, point} = insert_point(grid, x, y, item)

        place_elems(
          u_grid,
          rest_items,
          [point | active_list],
          k_samples,
          [point | placed_items],
          cell_size,
          radius,
          bounds
        )

      # If after k attempts no such point is found, instead remove i from the active list
      {:error, _} ->
        place_elems(grid, items, rest, k_samples, placed_items, cell_size, radius, bounds)
    end
  end

  def generate_point(a, b, c, d, e) do
    generate_point(a, b, c, d, e, nil)
  end

  def generate_point(_grid, _base_point, 0, _, _, _),
    do: {:error, "Failed to find a point after exhausting samples"}

  def generate_point(grid, %Fastfish.Point{} = base_point, k_samples, radius, bounds, nil) do
    # Choose a point from the spherical annulus between radius r and 2r around xi (the base_point)
    # Get a random angle (in radians, meaning a number between 0 and 2 * PI)
    angle = random_angle()

    # between radius r and 2r means
    p_radius = :rand.uniform() * (2 * radius) + radius

    # Convert angle & radius to coordinates, add base point coordinates to get absolute coordinates
    {x, y} =
      {base_point.x + p_radius * :math.cos(angle), base_point.y + p_radius * :math.sin(angle)}

    # So, are those coordinates okay ?
    # Our "map" has a finite size
    # And we don't want to be too close to other samples
    if out_of_bounds?(x, y, bounds) or too_close_to_someone?(x, y, bounds, grid, radius) do
      # Let's generate another of those *k* samples
      generate_point(grid, base_point, k_samples - 1, radius, bounds, nil)
    else
      # Everything's alright with this point
      {:ok, {x, y}}
    end
  end

  def too_close_to_someone?(x, y, {width, height}, grid, radius) do
    # Determine the sample of grid cells to check : 2 cells on every side of the inspected point, but beware of borders
    int_x = trunc(x)
    int_y = trunc(y)
    lower_x = max(int_x - 2, 0)
    upper_x = min(int_x + 3, width)
    lower_y = max(int_y - 2, 0)
    upper_y = min(int_y + 3, height)

    # Let's enumerate cells : remember that a cell is empty if it contains -1
    nonempty_cells =
      for cx <- Range.new(lower_x, upper_x),
          cy <- Range.new(lower_y, upper_y),
          cell = at_coords(grid, cx, cy),
          cell != -1 do
        cell
      end

    # Let's check if the populated cells are too close to our point
    # The distance between two points A and B is sqrt((A.x - B.x)^2 + (A.y - B.y)^2)
    # Too close means this distance is < to our minimum radius
    Enum.reduce(nonempty_cells, false, fn %Fastfish.Point{} = cell, flag ->
      if flag do
        flag
      else
        lx = x - cell.x
        ly = y - cell.y
        :math.sqrt(lx * lx + ly * ly) < radius
      end
    end)
  end

  @doc """
  Is the point at coordinates x, y in the universe ?
  """
  @spec out_of_bounds?(number(), number(), {number(), number()}) :: boolean
  def out_of_bounds?(x, y, {width, height}) do
    not (0 < x and
           x < width and
           0 < y and
           y < height)
  end

  @doc """
  Returns a random angle between 0 and 2PI
  """
  @spec random_angle :: float
  def random_angle, do: :rand.uniform() * :math.pi() * 2

  @doc """
  Inserts an item at a point of coordinates x and y in the closest cell in the universe
  """
  @spec insert_point(map(), number(), number(), any) :: {map(), Fastfish.Point.__struct__}
  def insert_point(grid, x, y, item) do
    point = Fastfish.Point.make(x, y, item)
    grid = update_in(grid, [trunc(x), trunc(y)], fn _ -> point end)
    {grid, point}
  end

  @doc """
  Returns the value at coords x,y in the universe.
  """
  @spec at_coords(map(), number(), number()) :: Fastfish.Point | -1
  def at_coords(grid, x, y) do
    Map.get(Map.get(grid, y, %{}), x, -1)
  end
end
