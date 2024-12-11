defmodule ScalesCms.Cms.CmsPageVariantBlock do
  @moduledoc false
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
    |> cast(attrs, [:sort_order, :component_type, :properties, :cms_page_variant_id])
    |> validate_required([:sort_order, :component_type])
  end

  def change_order_changeset(cms_page_variant_block, attrs) do
    cms_page_variant_block
    |> cast(attrs, [:sort_order])
    |> validate_required([:sort_order])
  end
end
