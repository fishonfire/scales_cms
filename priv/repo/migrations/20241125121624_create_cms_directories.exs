defmodule ScalesCms.Repo.Migrations.CreateCmsDirectories do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:cms_directories) do
      add :title, :text
      add :slug, :string
      add :deleted_at, :naive_datetime
      add :cms_directory_id, references(:cms_directories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists index(:cms_directories, [:cms_directory_id])
  end
end
