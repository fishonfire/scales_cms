defmodule GlorioCms.Repo.Migrations.CreateCmsPageVariants do
  use Ecto.Migration

  def change do
    create table(:cms_page_variants) do
      add :title, :text
      add :published_at, :naive_datetime
      add :locale, :string
      add :version, :integer
      add :cms_page_id, references(:cms_pages, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:cms_page_variants, [:cms_page_id])
    create index(:cms_page_variants, [:cms_page_id, :locale, :published_at])
  end
end
