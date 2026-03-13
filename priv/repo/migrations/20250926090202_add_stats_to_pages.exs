defmodule ScalesCms.Repo.Migrations.AddStatsToPages do
  use Ecto.Migration

  def change do
    alter table(:cms_pages) do
      add_if_not_exists :views, :integer, default: 0, null: false
      add_if_not_exists :path, :text
    end
  end
end
