defmodule ScalesCms.MixProject do
  use Mix.Project

  def project do
    [
      app: :scales_cms,
      version: "0.1.10",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      deps: deps(),
      elixirc_options: [
        warnings_as_errors: true
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ScalesCms.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    dep_list = [
      {:phoenix, "~> 1.7.17"},
      {:phoenix_ecto, "~> 4.6"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.5"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:junit_formatter, "~> 3.3", only: [:test]},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:hackney, "~> 1.9"},
      {:ex_aws, "~> 2.5"},
      {:ex_aws_s3, "~> 2.5"},
      {:credo, "~> 1.7", runtime: false, only: :dev},
      {:ex_doc, "~> 0.24", only: :dev}
    ]

    if Application.get_env(:scales_cms, :dev_mode) do
      dep_list ++
        [
          {:heroicons,
           github: "tailwindlabs/heroicons",
           tag: "v2.1.1",
           sparse: "optimized",
           app: false,
           compile: false,
           depth: 1,
           optional: true}
        ]
    else
      dep_list
    end
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind scales_cms", "esbuild scales_cms"],
      "assets.deploy": [
        "tailwind scales_cms --minify",
        "esbuild scales_cms --minify",
        "phx.digest"
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Simon de la Court"],
      description: "A page builder annex CMS made by Fish on Fire",
      licenses: ["GPL-3.0-or-later"],
      links: %{github: "https://github.com/fishonfire/scales_cms"},
      files: ~w(dist lib CHANGELOG.md LICENSE mix.exs README.md)
    ]
  end

  defp docs do
    [
      extras: ["README.md"]
    ]
  end
end
