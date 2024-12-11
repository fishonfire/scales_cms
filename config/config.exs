# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :scales_cms,
  endpoint: ScalesCmsWeb.Endpoint

config :scales_cms,
  repo: ScalesCms.Repo

config :scales_cms, :dev_mode, true

config :scales_cms,
  ecto_repos: [ScalesCms.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :scales_cms, ScalesCmsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ScalesCmsWeb.ErrorHTML, json: ScalesCmsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ScalesCms.PubSub,
  live_view: [signing_salt: "5Ttdf+uJ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :scales_cms, ScalesCms.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  scales_cms: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  scales_cms: [
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

config :ex_aws, :s3,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  bucket_name: System.get_env("S3_BUCKET_NAME"),
  region: System.get_env("AWS_REGION")

config :scales_cms,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  bucket: System.get_env("S3_BUCKET_NAME"),
  region: System.get_env("AWS_REGION")

config :scales_cms, :cms, default_locale: "nl-NL"

if config_env() == :test || config_env() == :dev do
  # Import environment specific config. This must remain at the bottom
  # of this file so it overrides the configuration defined above.
  import_config "#{config_env()}.exs"
end
