defmodule Fastfish.BenchMulti do
  def bench() do
    params = [
      {100, 30},
      {500, 30},
      {1000, 30},
      {2000, 30},
    ]

    Enum.each(params, fn {n, k_samples} ->
      list = 0..n |> Enum.map(fn _ ->
        :rand.uniform() * 50 + 20.0
      end) |> Enum.into([])
      Benchee.run(
      %{
        "Elixir, #{n} samples, k=#{k_samples}" => fn -> FastfishMultiradii.place(list, 10, k_samples) end,
        "Rust  , #{n} samples, k=#{k_samples}" => fn -> FastfishRS.sample_multiradii(list, 10.0, k_samples) end
      }
    )
    end)
end
end

Fastfish.BenchMulti.bench()
