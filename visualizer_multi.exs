list = 0..600 |> Enum.map(fn _ -> if (:rand.uniform() < 0.12), do: 6, else: 6 end)

samples = FastfishMultiradii.place(list, 5) |> Enum.reverse() |> Enum.map(fn c -> %{x: c.x, y: c.y, r: c.r} end)

template = File.read!("index.multi.template.html")

injected = String.replace(template, "%%FFSAMPLES%%", Jason.encode!(samples))

File.write!("index.multi.html", injected)
