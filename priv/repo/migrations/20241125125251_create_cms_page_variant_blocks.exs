defmodule GlorioCms.Repo.Migrations.CreateCmsPageVariantBlocks do
  use Ecto.Migration

  def change do
    create table(:cms_page_variant_blocks) do
      add :sort_order, :integer
      add :component_type, :string
      add :properties, :map, default: %{}
      add :cms_page_variant_id, references(:cms_page_variants, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:cms_page_variant_blocks, [:cms_page_variant_id])
    create index(:cms_page_variant_blocks, [:cms_page_variant_id, :sort_order])
  end
end
