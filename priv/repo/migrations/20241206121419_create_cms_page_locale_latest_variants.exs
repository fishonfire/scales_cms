defmodule ScalesCms.Repo.Migrations.CreateCmsPageLocaleLatestVariants do
  use Ecto.Migration

  def change do
    create table(:cms_page_locale_latest_variants) do
      add :cms_page_id, references(:cms_pages, on_delete: :nothing), null: false
      add :locale, :string, null: false
      add :cms_page_latest_variant_id, references(:cms_page_variants, on_delete: :nothing)

      add :cms_page_latest_published_variant_id,
          references(:cms_page_variants, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
