defmodule ScalesCmsWeb.Components.CmsComponents.ButtonCollection.ButtonCollectionProperties do
  @moduledoc """
  Schema for button collection properties.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ScalesCmsWeb.Components.CmsComponents.Button.ButtonProperties

  embedded_schema do
    embeds_many :buttons, ButtonProperties
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [])
    |> cast_embed(:buttons, with: &ButtonProperties.changeset/2)
    |> validate_required([])
  end
end
