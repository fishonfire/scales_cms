defmodule ScalesCms.Cms.CmsApiToken do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_api_tokens" do
    field :token, :string
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(api_token, attrs \\ %{}) do
    api_token
    |> cast(attrs, [:token, :expires_at])
    |> validate_required([])
    |> unique_constraint(:token)
  end
end
