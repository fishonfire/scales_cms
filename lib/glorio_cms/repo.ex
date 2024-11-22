defmodule GlorioCms.Repo do
  use Ecto.Repo,
    otp_app: :glorio_cms,
    adapter: Ecto.Adapters.Postgres
end
