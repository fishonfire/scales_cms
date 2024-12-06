defmodule GlorioCms.Repo.Migrations.CreateCmsPages do
  use Ecto.Migration

  def change do
    create table(:cms_pages) do
      add :title, :text
      add :slug, :string
      add :deleted_at, :naive_datetime
      add :cms_directory_id, references(:cms_directories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:cms_pages, [:cms_directory_id])
  end
end
