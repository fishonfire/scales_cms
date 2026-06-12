defmodule ScalesCms.Migrations.V6 do
  @moduledoc false
  use Ecto.Migration

  def up do
    create_if_not_exists table(:cms_api_tokens) do
      add :token, :text

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create_if_not_exists index(:cms_api_tokens, [:token], unique: true)
  end

  def down do
    drop_if_exists index(:cms_api_tokens, [:token])
    drop_if_exists table(:cms_api_tokens)
  end
end
