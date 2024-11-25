defmodule GlorioCms.Cms.CmsPageVariant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_page_variants" do
    field :version, :integer
    field :title, :string
    field :published_at, :naive_datetime
    field :locale, :string
    field :cms_page_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cms_page_variant, attrs) do
    cms_page_variant
    |> cast(attrs, [:title, :published_at, :locale, :version])
    |> validate_required([:title, :published_at, :locale, :version])
  end
end
