defmodule Fastfish do
  def sample_ex(w, h, d, k, i, j \\ []) do
    FastfishEx.sample(w, h, d, k, i, j)
  end

  def sample_rs(w, h, d, k, p) do
    FastfishRS.sample(w, h, d, k, p)
  end
end
