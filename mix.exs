defmodule Docception.MixProject do
  use Mix.Project

  def project do
    [
      app: :docception,
      version: "0.2.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings",
        list_unused_filters: true
      ]
    ]
  end

  def application do
    [ ]
  end

  defp deps do
    [
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.5", only: [:dev], runtime: false},
      {:temp, "~> 0.4"}
    ]
  end
end
