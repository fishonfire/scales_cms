defmodule ScalesCmsWeb.Components.CmsComponents.Header.HeaderProperties do
  @moduledoc """
  The schema for the MD component
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :title, :string
    field :subtitle, :string
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [:title, :subtitle])
    |> validate_required([])
  end
end
