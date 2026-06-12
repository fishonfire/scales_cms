defmodule ScalesCms.Migrations.V4 do
  @moduledoc false
  use Ecto.Migration

  def up do
    create_if_not_exists table(:cms_page_variant_blocks) do
      add :sort_order, :integer
      add :component_type, :string
      add :properties, :map, default: %{}
      add :cms_page_variant_id, references(:cms_page_variants, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists index(:cms_page_variant_blocks, [:cms_page_variant_id])
    create_if_not_exists index(:cms_page_variant_blocks, [:cms_page_variant_id, :sort_order])
  end

  def down do
    drop_if_exists index(:cms_page_variant_blocks, [:cms_page_variant_id, :sort_order])
    drop_if_exists index(:cms_page_variant_blocks, [:cms_page_variant_id])
    drop_if_exists table(:cms_page_variant_blocks)
  end
end
