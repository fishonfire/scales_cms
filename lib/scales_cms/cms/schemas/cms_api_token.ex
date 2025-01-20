defmodule ScalesCms.Cms.CmsApiToken do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_api_tokens" do
    field :token, :string

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(api_token, attrs \\ %{}) do
    api_token
    |> cast(attrs, [:token])
    |> validate_required([:token])
    |> unique_constraint(:token)
  end
end
