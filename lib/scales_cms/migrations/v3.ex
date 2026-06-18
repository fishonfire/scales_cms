defmodule ScalesCms.Migrations.V3 do
  @moduledoc false
  use Ecto.Migration

  def up do
    create_if_not_exists table(:cms_page_variants) do
      add :title, :text
      add :published_at, :naive_datetime
      add :locale, :string
      add :version, :integer
      add :cms_page_id, references(:cms_pages, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists index(:cms_page_variants, [:cms_page_id])
    create_if_not_exists index(:cms_page_variants, [:cms_page_id, :locale, :published_at])
  end

  def down do
    drop_if_exists index(:cms_page_variants, [:cms_page_id, :locale, :published_at])
    drop_if_exists index(:cms_page_variants, [:cms_page_id])
    drop_if_exists table(:cms_page_variants)
  end
end
