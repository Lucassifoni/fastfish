samples = Fastfish.sample_ex(1280, 720, 10, 30, 0..2000 |> Enum.to_list, [10, 20, 30])
  |> elem(1)
  |> Enum.map(fn p -> %{x: p.x, y: p.y, r: Map.get(p, :data, nil) |> elem(0)} end)

template = File.read!("scripts/index.template.html")

injected = String.replace(template, "%%FFSAMPLES%%", Jason.encode!(samples))

File.write!("index.html", injected)
