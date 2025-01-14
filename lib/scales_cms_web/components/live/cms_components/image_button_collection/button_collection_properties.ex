defmodule ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection.ImageButtonCollectionProperties do
  @moduledoc """
  Schema for button collection properties.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ScalesCmsWeb.Components.CmsComponents.ImageButton.ImageButtonProperties

  embedded_schema do
    embeds_many :buttons, ImageButtonProperties
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [])
    |> cast_embed(:buttons, with: &ImageButtonProperties.changeset/2)
    |> validate_required([])
  end
end
