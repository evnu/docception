defmodule Docception.MixProject do
  use Mix.Project

  def project do
    [
      app: :docception,
      version: "0.3.6",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      source_url: "https://github.com/evnu/docception",
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings",
        list_unused_filters: true,
        plt_add_apps: [:ex_unit, :mix]
      ],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [ ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:temp, "~> 0.4"}
    ]
  end

  defp description do
    "Running Elixir doctests on Markdown files"
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      links: %{"Github" => "https://github.com/evnu/docception"},
      maintainers: ["evnu"]
    ]
  end
end
