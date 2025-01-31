defmodule Hedwig.Mixfile do
  use Mix.Project

  @version "1.0.1"

  def project do
    [
      app: :hedwig,
      version: @version,
      elixir: "~> 1.13",
      docs: docs(),
      deps: deps(),
      package: package(),
      name: "Hedwig",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "An adapter-based chat bot framework",
      source_url: "https://github.com/ircdev/hedwig",
      homepage_url: "https://github.com/ircdev/hedwig",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test
      ]
    ]
  end

  def application do
    [
      mod: {Hedwig, []},
      extra_applications: [
        :logger,
        :eex
      ]
    ]
  end

  defp docs do
    [extras: docs_extras(), main: "readme"]
  end

  defp docs_extras do
    ["README.md"]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.32", only: :dev},
      {:styler, "~> 1.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Graham McIntire", "Sonny Scroggin"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/ircdev/hedwig",
        "Docs" => "https://hexdocs.pm/hedwig"
      }
    ]
  end
end
