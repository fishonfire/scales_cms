defmodule GlorioCmsWeb.Components.CmsComponents.Image.ImageProperties do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :image_url, :string
    field :filename, :string
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [:image_url])
    |> validate_required([])
  end
end
