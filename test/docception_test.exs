defmodule DocceptionTest do
  use ExUnit.Case

  test "raises if no files present" do
    assert_raise Docception.Error, fn ->
      Docception.run([])
    end
  end

  test "raises if file does not exist" do
    assert_raise Docception.Error, fn ->
      Docception.run(["doesnotexist"])
    end
  end
end
