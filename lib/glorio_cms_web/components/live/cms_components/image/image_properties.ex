defmodule GlorioCmsWeb.Components.CmsComponents.Image.ImageProperties do
  @moduledoc """
  The image upload component schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :image_url, :string
    field :image_path, :string
    field :filename, :string
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [:image_url, :image_path])
    |> validate_required([])
  end
end
