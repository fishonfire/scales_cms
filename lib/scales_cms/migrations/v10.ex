defmodule ScalesCms.Migrations.V10 do
  @moduledoc false
  use Ecto.Migration

  def up do
    create_if_not_exists table(:cms_block_templates) do
      add :name, :string
      add :component_type, :string
      add :properties, :map, default: %{}
      add :locale, :string
      add :template_family_id, :uuid, null: false
      add :template_mode, :string, default: "live"
      add :published_at, :utc_datetime, default: nil

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists index(:cms_block_templates, [:template_family_id])
    create_if_not_exists unique_index(:cms_block_templates, [:template_family_id, :locale])
  end

  def down do
    drop_if_exists index(:cms_block_templates, [:template_family_id, :locale])
    drop_if_exists index(:cms_block_templates, [:template_family_id])
    drop_if_exists table(:cms_block_templates)
  end
end
