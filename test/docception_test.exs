defmodule DocceptionTest do
  use ExUnit.Case
  doctest Docception

  test "greets the world" do
    assert Docception.hello() == :world
  end
end
