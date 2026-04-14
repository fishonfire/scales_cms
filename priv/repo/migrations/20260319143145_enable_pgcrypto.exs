defmodule ScalesCms.Repo.Migrations.EnablePgcrypto do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto", "DROP EXTENSION IF EXISTS pgcrypto")
  end
end
