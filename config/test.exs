import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :scales_cms, ScalesCms.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "test_cms_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :scales_cms, ScalesCmsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "sMMf7ufR+q6ehSv7TGmRJHQp1nkUYxY3ndnr0DOKUQo2bRnkFJhb2Zz5spRLl+/J",
  server: false

# In test we don't send emails
config :scales_cms, ScalesCms.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :junit_formatter,
  report_dir: "/tmp",
  # Save output to "/tmp/junit.xml"
  report_file: "junit.xml",
  # Adds information about file location when suite finishes
  print_report_file: true,
  # Include filename and file number for more insights
  include_filename?: true,
  include_file_line?: true
