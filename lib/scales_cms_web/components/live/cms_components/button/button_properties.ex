defmodule ScalesCmsWeb.Components.CmsComponents.Button.ButtonProperties do
  @moduledoc """
  The schema for the MD component
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :title, :string
    field :subtitle, :string
    field :icon, :string

    field :page_id, :integer
    field :url, :string
    field :payload, :string
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [:title, :subtitle, :icon, :page_id, :url, :payload])
    |> validate_required([])
  end
end
