samples = FastfishRS.demo_multiradii |> Enum.reverse() |> Enum.map(fn {x, y, r} -> %{x: x, y: y, r: r} end)

template = File.read!("scripts/index.multi.template.html")

injected = String.replace(template, "%%FFSAMPLES%%", Jason.encode!(samples))

File.write!("index.multi.html", injected)
