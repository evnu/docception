defmodule Mix.Tasks.Docception do
  use Mix.Task

  @moduledoc """
  Docception -- run doctests on arbitrary markdown files

  # Usage

      mix docception markdown-files

  """

  @shortdoc "Run doctests on arbitrary markdown files"

  def run(files) do
    # Compile first to ensure that all dependencies and parent project's module are available in
    # doctests.
    Mix.Task.run "compile"

    ExUnit.start()

    verbose? = true

    Docception.run(files, verbose?)
  rescue
    e in Docception.Error ->
      Mix.raise("Docception: #{e.message}")
  after
    # Stop ExUnit manually in order to try to let it write the error messages.
    Application.stop(:ex_unit)
  end
end
