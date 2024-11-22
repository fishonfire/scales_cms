# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :glorio_cms,
  ecto_repos: [GlorioCms.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :glorio_cms, GlorioCmsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: GlorioCmsWeb.ErrorHTML, json: GlorioCmsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GlorioCms.PubSub,
  live_view: [signing_salt: "5Ttdf+uJ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :glorio_cms, GlorioCms.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  glorio_cms: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  glorio_cms: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure your database
config :glorio_cms, GlorioCms.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "glorio_cms_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :junit_formatter,
  report_dir: "/tmp",
  # Save output to "/tmp/junit.xml"
  report_file: "junit.xml",
  # Adds information about file location when suite finishes
  print_report_file: true,
  # Include filename and file number for more insights
  include_filename?: true,
  include_file_line?: true

if config_env() == :test do
  # Import environment specific config. This must remain at the bottom
  # of this file so it overrides the configuration defined above.
  import_config "#{config_env()}.exs"
end
