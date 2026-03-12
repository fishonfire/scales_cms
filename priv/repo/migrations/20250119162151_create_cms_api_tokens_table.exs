defmodule ScalesCms.Repo.Migrations.CreateCmsApiTokensTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:cms_api_tokens) do
      add :token, :text

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create_if_not_exists index(:cms_api_tokens, [:token], unique: true)
  end
end
