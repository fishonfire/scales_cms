defmodule ScalesCms.Cms.CmsDirectory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_directories" do
    field :title, :string
    field :slug, :string
    field :deleted_at, :naive_datetime
    field :cms_directory_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cms_directory, attrs) do
    cms_directory
    |> cast(attrs, [:title, :slug, :cms_directory_id, :deleted_at])
    |> validate_required([:title, :slug])
  end
end
