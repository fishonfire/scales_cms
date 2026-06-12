defmodule ScalesCms.Migrations.V1 do
  @moduledoc false
  use Ecto.Migration

  def up do
    create_if_not_exists table(:cms_directories) do
      add :title, :text
      add :slug, :string
      add :deleted_at, :naive_datetime
      add :cms_directory_id, references(:cms_directories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists index(:cms_directories, [:cms_directory_id])
  end

  def down do
    drop_if_exists index(:cms_directories, [:cms_directory_id])
    drop_if_exists table(:cms_directories)
  end
end
