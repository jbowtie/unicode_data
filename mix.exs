defmodule UnicodeData.Mixfile do
  use Mix.Project

  @version "0.8.0"

  def project do
    [
      app: :unicode_data,
      version: @version,
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      description: "Exposes Unicode properties needed for layout and analysis.",
      package: package(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.24.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13.3", only: :test},
      {:inch_ex, "~> 2.0.0", only: :docs}
    ]
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      name: "unicode_data",
      maintainers: ["jbowtie/John C Barstow"],
      links: %{
        "GitHub" => "https://github.com/jbowtie/unicode_data",
        "GitLab" => "https://gitlab.com/jbowtie/unicode_data"
      }
    ]
  end
end
