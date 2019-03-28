defmodule Docception do
  @moduledoc """
  Main Docception library.

  This library is to be used by `Mix.Tasks.Docception`.
  """

  alias Docception.Error

  alias ExUnit.DocTest

  @doc """
  Main entry point.

  ## Raises

  This function raises `Docception.Error` on errors.
  """
  def run(files) when is_list(files) do
    if Enum.empty?(files) do
      raise Docception.Error, "No files to check"
    end

    files
    |> check_files_exist!()
    |> files_as_beams!()
    |> docception()
  end

  defp check_files_exist!(files) do
    Enum.each(files, fn f ->
      unless File.exists?(f) do
        raise Error, "File #{inspect(f)} does not exist."
      end
    end)

    files
  end

  defp files_as_beams!(files) do
    Enum.map(files, &file_as_beam!/1)
  end

  # Transform a file into an Elixir module
  defp file_as_beam!(file) do
    name = Path.basename(file)

    file
    |> File.stream!()
    |> stream_as_beam(name)
  end

  @doc false
  def stream_as_beam(stream, name) do
    if stream.line_or_bytes != :line do
      raise Error, "internal error: expect stream to be line-wise"
    end

    escaped = Enum.map(stream, &String.replace(&1, ~S("""), ~S(\""")))

    module = Module.concat(Docception, String.to_atom(name))

    wrapped = ~s(
    defmodule #{inspect(module)} do
      @moduledoc """
      #{escaped}
      """
    end
    )

    compiler_options = Code.compiler_options()

    Code.compiler_options(ignore_module_conflict: true)

    [{module, byte_code}] = Code.compile_string(wrapped)

    Code.compiler_options(compiler_options)

    {module, byte_code}
  end

  defp docception(files_as_beams) do
    {:ok, tmp_dir} = Temp.path("docception")

    File.mkdir(tmp_dir)

    try do
      tmp_dir |> String.to_charlist() |> :code.add_patha()

      results = Enum.flat_map(files_as_beams, &eval_module(&1, tmp_dir))

      if Enum.any?(results, &(&1 != :normal)) do
        raise Error, "Failed tests found"
      end
    after
      File.rm_rf(tmp_dir)
    end
  end

  defp eval_module({module, byte_code}, tmp_dir) do
    # Note that the .beam extension is added by :code.load_abs/1
    # See https://stackoverflow.com/a/42512734; we need to write a file to retrieve the
    # docs.
    tmp_beam = Path.join(tmp_dir, Atom.to_string(module) <> ".beam")

    File.write!(tmp_beam, byte_code)
    # Ensure that we start with a clean state
    :code.purge(module)

    module
    |> DocTest.__doctests__([])
    |> Enum.map(fn {_name, test} ->
      # Spawn a process and wait for it to die.
      pid =
        spawn(fn ->
          Code.compile_quoted(test)
        end)

      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, :process, ^pid, reason} ->
          case reason do
            :normal -> :ok
            _ -> :unnormal
          end
      end
    end)
  end
end
