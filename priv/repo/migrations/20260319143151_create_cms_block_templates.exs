defmodule ScalesCms.Repo.Migrations.CreateCmsBlockTemplates do
  use Ecto.Migration

  def change do
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

    create index(:cms_block_templates, [:template_family_id])
    create unique_index(:cms_block_templates, [:template_family_id, :locale])
  end
end
