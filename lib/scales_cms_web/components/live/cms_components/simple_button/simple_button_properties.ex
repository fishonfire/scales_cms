defmodule ScalesCmsWeb.Components.CmsComponents.SimpleButton.SimpleButtonProperties do
  @moduledoc """
  The schema for the MD component
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :title, :string

    field :page_id, :integer
    field :url, :string
    field :payload, :string
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [:title, :page_id, :url, :payload])
    |> validate_required([])
  end
end
