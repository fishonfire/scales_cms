defmodule GlorioCms.Cms.CmsPageLocaleLatestVariant do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_page_locale_latest_variants" do
    field :locale, :string
    field :cms_page_latest_published_variant_id, :id
    field :cms_page_latest_variant_id, :id
    field :cms_page_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cms_page_variant, attrs) do
    cms_page_variant
    |> cast(attrs, [
      :locale,
      :cms_page_latest_published_variant_id,
      :cms_page_latest_variant_id,
      :cms_page_id
    ])
    |> validate_required([
      :cms_page_id,
      :locale,
      :cms_page_latest_published_variant_id,
      :cms_page_latest_variant_id
    ])
  end
end
