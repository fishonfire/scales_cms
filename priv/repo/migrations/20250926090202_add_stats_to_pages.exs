defmodule ScalesCms.Repo.Migrations.AddStatsToPages do
  use Ecto.Migration

  def change do
    alter table(:cms_pages) do
      add :views, :integer, default: 0, null: false
      add :path, :text
    end
  end
end
