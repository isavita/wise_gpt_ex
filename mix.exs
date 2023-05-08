defmodule WiseGPTEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :wise_gpt_ex,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Aleksandar Dimov"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/isavita/wise_gpt_ex"}
    ]
  end
end
