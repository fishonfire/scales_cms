defmodule GlorioCmsWeb.Components.CmsComponents.Md.MdProperties do
  @moduledoc """
  The schema for the MD component
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :content, :string
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [:content])
    |> validate_required([])
  end
end
