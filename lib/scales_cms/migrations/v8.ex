defmodule ScalesCms.Migrations.V8 do
  @moduledoc false
  use Ecto.Migration

  def up do
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

  def down do
    drop_if_exists index(:cms_media_library, [:deleted_at])
    drop_if_exists index(:cms_media_library, [:type])
    drop_if_exists table(:cms_media_library)
  end
end
