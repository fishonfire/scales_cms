defmodule ScalesCms.Migrations.V9 do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto")
  end

  def down do
    execute("DROP EXTENSION IF EXISTS pgcrypto")
  end
end
