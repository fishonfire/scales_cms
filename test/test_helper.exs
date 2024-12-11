ExUnit.start()
ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])
Ecto.Adapters.SQL.Sandbox.mode(ScalesCms.Repo, :manual)
