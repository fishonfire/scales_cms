defmodule ScalesCmsWeb.Components.CmsComponents.Button.ButtonProperties do
  @moduledoc """
  The schema for the MD component
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :bg_color_variant, :string
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
    |> cast(attrs, [:bg_color_variant, :title, :subtitle, :icon, :page_id, :url, :payload])
    |> validate_required([])
  end
end
