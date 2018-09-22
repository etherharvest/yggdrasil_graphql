defmodule YggdrasilGraphql.MixProject do
  use Mix.Project

  @version "0.1.0"
  @root "https://github.com/gmtprime/yggdrasil_graphql"

  def project do
    [
      app: :yggdrasil_graphql,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  #############
  # Application

  def application do
    [
      extra_applications: [:logger],
      mod: {Yggdrasil.GraphQL.Application, []}
    ]
  end

  defp deps do
    [
      {:yggdrasil, "~> 4.1"},
      {:absinthe, "~> 1.4"},
      {:uuid, "~> 1.1", only: [:dev, :test]},
      {:absinthe_phoenix, "~> 1.4", only: :test},
      {:ex_doc, "~> 0.18.4", only: :dev},
      {:credo, "~> 0.9", only: :dev}
    ]
  end

  #########
  # Package

  defp package do
    [
      description: "GraphQL adapter for Yggdrasil (pub/sub)",
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Alexander de Sousa"],
      licenses: ["MIT"],
      links: %{
        "Github" => @root
      }
    ]
  end

  ###############
  # Documentation

  defp docs do
    [
      source_url: @root,
      source_ref: "v#{@version}",
      main: Yggdrasil.GraphQL,
      formatters: ["html"],
      groups_for_modules: groups_for_modules()
    ]
  end

  defp groups_for_modules do
    [
      "GraphQL": [
        Yggdrasil.GraphQL
      ],
      "Application": [
        Yggdrasil.GraphQL.Application
      ],
      "Adapter": [
        Yggdrasil.Settings.GraphQL,
        Yggdrasil.Adapter.GraphQL
      ],
      "Subscriber adapter": [
        Yggdrasil.Subscriber.Adapter.GraphQL
      ],
      "Backend": [
        Yggdrasil.Backend.GraphQL
      ]
    ]
  end
end
