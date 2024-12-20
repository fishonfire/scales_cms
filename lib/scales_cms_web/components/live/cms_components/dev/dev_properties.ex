defmodule ScalesCmsWeb.Components.CmsComponents.Dev.DevProperties do
  @moduledoc """
  The schema for the MD component
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :component_type, :string
    field :properties, :string
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [:component_type, :properties])
    |> validate_required([])
  end
end
