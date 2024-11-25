defmodule GlorioCms.Cms.CmsPageVariantBlock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_page_variant_blocks" do
    field :sort_order, :integer
    field :component_type, :string
    field :properties, :map
    field :cms_page_variant_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cms_page_variant_block, attrs) do
    cms_page_variant_block
    |> cast(attrs, [:sort_order, :component_type, :properties])
    |> validate_required([:sort_order, :component_type])
  end
end
