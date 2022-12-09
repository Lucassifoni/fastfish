defmodule Fastfish.Bench do
  def bench() do
    params = [
      {100, 500, 5.0, 30},
      {10000, 5000, 5.0, 30},
      {20000, 25000, 5.0, 30},
      {20000, 5000, 5.0, 30},
      {100, 500, 5.0, 60},
      {10000, 5000, 5.0, 60},
      {20000, 25000, 5.0, 60},
      {20000, 5000, 5.0, 60}
    ]

    Enum.each(params, fn {items, side, distance, k_samples} ->
      ex_items = 0..items |> Enum.into([])
      Benchee.run(
      %{
        "Elixir , #{side}x#{side} grid, #{items} samples, k=#{k_samples}" => fn -> FastfishEx.sample(side, side, distance, k_samples, ex_items) end,
        "Rust   , #{side}x#{side} grid, #{items} samples, k=#{k_samples}" => fn -> FastfishRS.sample(side, side, distance, k_samples, items) end
      }
    )
    end)
end
end

Fastfish.Bench.bench()
