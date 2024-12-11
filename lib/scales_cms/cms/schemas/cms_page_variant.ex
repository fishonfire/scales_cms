defmodule ScalesCms.Cms.CmsPageVariant do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_page_variants" do
    field :version, :integer
    field :title, :string
    field :published_at, :naive_datetime
    field :locale, :string

    has_many :blocks, ScalesCms.Cms.CmsPageVariantBlock, preload_order: [asc: :sort_order]
    belongs_to :page, ScalesCms.Cms.CmsPage, foreign_key: :cms_page_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cms_page_variant, attrs) do
    cms_page_variant
    |> cast(attrs, [:title, :published_at, :locale, :version, :cms_page_id])
    |> validate_required([:title, :locale, :version])
  end
end
