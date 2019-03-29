defmodule Example.MixProject do
  use Mix.Project

  def project do
    [
      app: :example,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [test: &test/1]
    ]
  end

  def test(_args) do
    Mix.Task.run("docception", ["README.md"])
  end

  def application do
    [ ]
  end

  defp deps do
    [
      {:docception, path: "../"}
    ]
  end
end
