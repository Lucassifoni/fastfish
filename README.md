# Fastfish

Fast poisson disk sampling in 2D in Elixir (& Elixir + Rust)

## Origins of the algorithm
I stumbled on this **elegant visualisation by Jason Davies** (https://www.jasondavies.com/poisson-disc/), based on the paper **"Fast Poisson Disk Sampling in Arbitrary Dimensions" by Robert Bridson, University of British Columbia.**

I was looking for an algorithm to place items on a bounded map with an homogenous repartition with a natural feel.

The linked paper on J.Davies's website was really interesting because of its conciseness and clarity. It fits on a single page.

## Implementation - read a paper together

The code in `fastfish.ex` is **heavily commented** to read along the paper. The main difference is that I need to place a specific number of items with this repartition in an universe, so I don't fill the available space but stop when my items are placed.

![the paper, a paragraph, code implementing it](image.png)

## Usage

Don't count on a stable API since I published this mainly to show how you can follow along a concise paper and work through it, but :

```elixir
Fastfish.sample(universe_width, universe_height, distance, k_samples, items)
```


```iex
iex(1)> Fastfish.sample(200, 200, 5, 30, 0..10 |> Enum.into([]))
{:ok,
 [
   %Fastfish.Point{x: 133.22702823516536, y: 68.62183195726422, data: 5},
   %Fastfish.Point{x: 130.03055811979786, y: 74.08996948304181, data: 3},
   %Fastfish.Point{x: 121.11434113919326, y: 82.51976141062774, data: 8},
   %Fastfish.Point{x: 93.08747429977802, y: 78.97486701773849, data: 7},
   %Fastfish.Point{x: 123.58411706348512, y: 72.93372906377856, data: 9},
   %Fastfish.Point{x: 99.09686656561144, y: 79.22608607040829, data: 4},
   %Fastfish.Point{x: 124.16568387689189, y: 81.47519363081939, data: 2},
   %Fastfish.Point{x: 123.21458608552476, y: 88.83203333625944, data: 10},
   %Fastfish.Point{x: 109.35402808482807, y: 84.39153817302201, data: 6},
   %Fastfish.Point{x: 104.09928570715282, y: 97.64056451070834, data: 0},
   %Fastfish.Point{x: 97.5, y: 97.5, data: 1}
 ]}
```

## Rust NIF

A rust NIF reimplements the `sample/5` function. Here are some benchmarks.
It seems that the fixed cost of calling into Rust dominates when I need only a few elements. Grid size :

```
Name                                                       ips        average  deviation         median         99th %
Elixir implementation, 500x500 grid, 100 samples        1.25 K        0.80 ms     ±7.62%        0.79 ms        0.94 ms
Rust implementation, 500x500 grid, 100 samples          0.24 K        4.08 ms     ±1.91%        4.07 ms        4.29 ms

Comparison:
Elixir implementation, 500x500 grid, 100 samples        1.25 K
Rust implementation, 500x500 grid, 100 samples          0.24 K - 5.10x slower +3.28 ms

---

Name                                                           ips        average  deviation         median         99th %
Rust implementation, 5000x5000 grid, 10000 samples            2.22         0.45 s     ±1.17%         0.45 s         0.46 s
Elixir implementation, 5000x5000 grid, 10000 samples         0.147         6.82 s     ±0.00%         6.82 s         6.82 s

Comparison:
Rust implementation, 5000x5000 grid, 10000 samples            2.22
Elixir implementation, 5000x5000 grid, 10000 samples         0.147 - 15.16x slower +6.37 s

---

Name                                                             ips        average  deviation         median         99th %
Rust implementation, 25000x25000 grid, 20000 samples           0.105         9.51 s     ±0.00%         9.51 s         9.51 s
Elixir implementation, 25000x25000 grid, 20000 samples        0.0336        29.75 s     ±0.00%        29.75 s        29.75 s

Comparison:
Rust implementation, 25000x25000 grid, 20000 samples           0.105
Elixir implementation, 25000x25000 grid, 20000 samples        0.0336 - 3.13x slower +20.24 s

---

Name                                                           ips        average  deviation         median         99th %
Rust implementation, 5000x5000 grid, 20000 samples            1.87         0.54 s     ±2.77%         0.53 s         0.56 s
Elixir implementation, 5000x5000 grid, 20000 samples        0.0328        30.47 s     ±0.00%        30.47 s        30.47 s

Comparison:
Rust implementation, 5000x5000 grid, 20000 samples            1.87
Elixir implementation, 5000x5000 grid, 20000 samples        0.0328 - 56.86x slower +29.93 s
```

## Roadmap

- [ ] Compare the naïve implementation backed by a map to other data structures
- [x] Rust FFI via Rustler to build coordinates faster