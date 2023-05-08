defmodule WiseGPTEx.MixProject do
  use Mix.Project

  @version "0.1.0"
  @docs_url "http://hexdocs.pm/wise_gpt_ex"
  @github_url "https://github.com/isavita/wise_gpt_ex"

  def project do
    [
      app: :wise_gpt_ex,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      name: "WiseGPTEx",
      source_url: @github_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:httpoison, "~> 1.8"},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "WiseGPTEx is a smart Elixir library that employs GPT-4/GPT-3.5-turbo for advanced question answering. It generates multiple answers, leveraging a chain of thoughts approach to select the best response."
  end

  defp package do
    [
      name: "wise_gpt_ex",
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Aleksandar Dimov"],
      licenses: ["Apache-2.0"],
      links: %{
        "Docs" => @docs_url,
        "GitHub" => @github_url
      }
    ]
  end
end
