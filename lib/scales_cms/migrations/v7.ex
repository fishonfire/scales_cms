defmodule ScalesCms.Migrations.V7 do
  @moduledoc false
  use Ecto.Migration

  def up do
    alter table(:cms_pages) do
      add_if_not_exists :views, :integer, default: 0, null: false
      add_if_not_exists :path, :text
    end
  end

  def down do
    alter table(:cms_pages) do
      remove_if_exists :views, :integer
      remove_if_exists :path, :text
    end
  end
end
