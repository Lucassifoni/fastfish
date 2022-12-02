defmodule Fastfish.Rsnif do
  use Rustler, otp_app: :fastfish, crate: :fastfish_rsnif

  def sample(_width, _height, _distance, _k_samples, _positions), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
