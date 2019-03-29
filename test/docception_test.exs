defmodule DocceptionTest do
  use ExUnit.Case

  @source "testfile.md"
  @file_name "testfile.md"

  test "raises if no files present" do
    assert_raise Docception.Error, fn ->
      Docception.run([], false)
    end
  end

  test "raises if file does not exist" do
    assert_raise Docception.Error, fn ->
      Docception.run(["doesnotexist"], false)
    end
  end

  test "converts test files into beam" do
    assert {@file_name, :"Elixir.Docception.testfile.md", _beam} =
             failing_test_file() |> Docception.stream_as_beam(@file_name, @source)

    assert {@file_name, :"Elixir.Docception.testfile.md", _beam} =
             succeeding_test_file() |> Docception.stream_as_beam(@file_name, @source)

    assert_raise Docception.Error, fn ->
      # Expect line-wise stream
      Docception.stream_as_beam(StringIO.open("") |> IO.stream(10), @file_name, @source)
    end
  end

  test "does not fail on correct test" do
    file_as_beam = succeeding_test_file() |> Docception.stream_as_beam(@file_name, @source)

    assert :ok == Docception.docception([file_as_beam], false)
  end

  test "finds a failing test" do
    file_as_beam = failing_test_file() |> Docception.stream_as_beam(@file_name, @source)

    assert_raise Docception.Error, fn ->
      # This will write to stdout, but can apparently not be captured.
      # Possibly because of a sub-process with another group leader.
      Docception.docception([file_as_beam], false)
    end
  end

  defp failing_test_file do
    {:ok, io} =
      StringIO.open("""
      This is a test file. It contains a failing test:

        iex> :failing_test
        true

      """)

    IO.stream(io, :line)
  end

  defp succeeding_test_file do
    {:ok, io} =
      StringIO.open("""
      This is a test file. It contains a succeeding test:

        iex> true
        true

      """)

    IO.stream(io, :line)
  end
end
