defmodule Fastfish.Bench do
  def bench() do
    items = 0..100 |> Enum.into([])
    width = 500
    height = 500
    d = 5.0
    k = 30
    p = 100
    Benchee.run(
      %{
        "Elixir implementation, #{width}x#{height} grid, #{p} samples" => fn -> FastfishEx.sample(width, height, d, k, items) end,
        "Rust implementation, #{width}x#{height} grid, #{p} samples" => fn -> FastfishRS.sample(width, height, d, k, p) end
      }
    )

    items = 0..10000 |> Enum.into([])
    width = 5000
    height = 5000
    d = 5.0
    k = 30
    p = 10000
    Benchee.run(
      %{
        "Elixir implementation, #{width}x#{height} grid, #{p} samples" => fn -> FastfishEx.sample(width, height, d, k, items) end,
        "Rust implementation, #{width}x#{height} grid, #{p} samples" => fn -> FastfishRS.sample(width, height, d, k, p) end
      }
    )

    items = 0..20000 |> Enum.into([])
    width = 25000
    height = 25000
    d = 5.0
    k = 30
    p = 20000
    Benchee.run(
      %{
        "Elixir implementation, #{width}x#{height} grid, #{p} samples" => fn -> FastfishEx.sample(width, height, d, k, items) end,
        "Rust implementation, #{width}x#{height} grid, #{p} samples" => fn -> FastfishRS.sample(width, height, d, k, p) end
      }
    )

    items = 0..20000 |> Enum.into([])
    width = 5000
    height = 5000
    d = 5.0
    k = 30
    p = 20000
    Benchee.run(
      %{
        "Elixir implementation, #{width}x#{height} grid, #{p} samples" => fn -> FastfishEx.sample(width, height, d, k, items) end,
        "Rust implementation, #{width}x#{height} grid, #{p} samples" => fn -> FastfishRS.sample(width, height, d, k, p) end
      }
    )
  end
end

Fastfish.Bench.bench()
