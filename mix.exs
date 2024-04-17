defmodule DepsNix.MixProject do
  use Mix.Project

  @scm_url "https://github.com/code-supply/deps_nix"

  def project do
    [
      app: :deps_nix,
      deps: deps(),
      description: "Mix task that converts Mix dependencies to Nix derivations",
      dialyzer: [plt_add_apps: [:mix]],
      elixir: "~> 1.16",
      package: package(),
      source_url: @scm_url,
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
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
      {:jason, "~> 1.4"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:stream_data, "~> 0.6.0", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      links: %{"GitHub" => @scm_url},
      licenses: ["MIT"]
    ]
  end
end
