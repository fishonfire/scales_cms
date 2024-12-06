defmodule GlorioCms.Cms.CmsPage do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_pages" do
    field :title, :string
    field :slug, :string
    field :deleted_at, :naive_datetime
    field :cms_directory_id, :id

    has_many :cms_page_variants, GlorioCms.Cms.CmsPageVariant

    has_many :cms_page_locale_latest_variants, GlorioCms.Cms.CmsPageLocaleLatestVariant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cms_page, attrs) do
    cms_page
    |> cast(attrs, [:title, :slug, :cms_directory_id, :deleted_at])
    |> validate_required([:title, :slug])
  end
end
