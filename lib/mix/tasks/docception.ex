defmodule Mix.Tasks.Docception do
  use Mix.Task

  @moduledoc """
  Docception -- run doctests on arbitrary markdown files

  # Usage

      mix docception files

  """

  @shortdoc "Run doctests on arbitrary markdown files"

  def run(files) do
    ExUnit.start()

    verbose? = true

    Docception.run(files, verbose?)
  rescue
    e in Docception.Error -> Mix.raise("Docception: #{e.message}")
  end
end
