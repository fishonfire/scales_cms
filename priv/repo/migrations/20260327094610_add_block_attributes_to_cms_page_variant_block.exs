defmodule ScalesCms.Repo.Migrations.AddBlockTemplateAttributesToCmsPageVariantBlock do
  use Ecto.Migration

  def change do
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
end
