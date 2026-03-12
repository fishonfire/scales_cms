defmodule ScalesCms.Repo.Migrations.CreateCmsMediaLibrary do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:cms_media_library) do
      add :name, :text
      add :type, :string
      add :url, :text
      add :deleted_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists index(:cms_media_library, [:type])
    create_if_not_exists index(:cms_media_library, [:deleted_at])
  end
end
