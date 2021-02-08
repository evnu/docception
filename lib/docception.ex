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
  def run(files, verbose?) when is_list(files) do
    if Enum.empty?(files) do
      raise Docception.Error, "No files to check"
    end

    files
    |> check_files_exist!()
    |> files_as_beams!()
    |> docception(verbose?)
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
    file_name = Path.basename(file)

    file
    |> File.stream!()
    |> stream_as_beam(file_name, file)
  end

  @doc false
  def stream_as_beam(stream, file_name, file) do
    if stream.line_or_bytes != :line do
      raise Error, "internal error: expect stream to be line-wise"
    end

    escaped =
      stream
      |> Stream.map(&String.trim_leading/1)
      |> Stream.map(&String.trim_trailing(&1, "\n"))
      |> Enum.join("\n")

    module = Module.concat(Docception, String.to_atom(file_name))

    {:ok, binary} = :beam_me.string_to_beam(module, escaped, String.to_charlist(file))

    {file_name, module, binary}
  end

  @doc false
  def docception(files_as_beams, verbose?) do
    {:ok, tmp_dir} = Temp.path("docception")

    File.mkdir(tmp_dir)

    try do
      tmp_dir |> String.to_charlist() |> :code.add_patha()

      results = Enum.flat_map(files_as_beams, &eval_module(&1, tmp_dir, verbose?))

      if Enum.any?(results, &(&1 != :normal)) do
        raise Error, "Failed tests found"
      else
        message = "#{length(results)} doctests passed"
        IO.puts(IO.ANSI.format_fragment([:green, to_charlist(message)]))

        :ok
      end
    after
      File.rm_rf(tmp_dir)
    end
  end

  defp eval_module({file_name, module, byte_code}, tmp_dir, verbose?) do
    if verbose? do
      IO.puts("Docception: #{file_name}")
    end

    tmp_beam = Path.join(tmp_dir, Atom.to_string(module) <> ".beam")

    # Code.fetch_docs/1 requires the beam to be present in the file system
    File.write!(tmp_beam, byte_code)

    module
    |> DocTest.__doctests__([])
    |> Enum.map(fn {_name, test} ->
      # Spawn a process and wait for it to die.
      {pid, ref} =
        spawn_monitor(fn ->
          Code.compile_quoted(test, file_name)
        end)

      receive do
        {:DOWN, ^ref, :process, ^pid, reason} ->
          reason
      end
    end)
  end
end
