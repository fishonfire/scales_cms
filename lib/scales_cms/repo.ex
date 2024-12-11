defmodule ScalesCms.Repo do
  use Ecto.Repo,
    otp_app: :scales_cms,
    adapter: Ecto.Adapters.Postgres
end
