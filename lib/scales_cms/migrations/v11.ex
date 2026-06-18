defmodule ScalesCms.Migrations.V11 do
  @moduledoc false
  use Ecto.Migration

  def up do
    alter table(:cms_page_variant_blocks) do
      add :block_template_family_id, :uuid
      add :block_template_mode, :string, default: nil
    end

    create index(
             :cms_page_variant_blocks,
             [:block_template_family_id],
             where: "block_template_family_id IS NOT NULL"
           )
  end

  def down do
    drop_if_exists index(:cms_page_variant_blocks, [:block_template_family_id])

    alter table(:cms_page_variant_blocks) do
      remove_if_exists :block_template_family_id, :uuid
      remove_if_exists :block_template_mode, :string
    end
  end
end
