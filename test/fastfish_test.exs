defmodule FastfishTest do
  use ExUnit.Case
  doctest Fastfish

  test "greets the world" do
    assert Fastfish.hello() == :world
  end
end
