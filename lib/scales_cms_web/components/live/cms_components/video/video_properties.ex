defmodule ScalesCmsWeb.Components.CmsComponents.Video.VideoProperties do
  @moduledoc """
  The video component schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :title, :string
    field :subtitle, :string
    field :video_url, :string
    field :autoplay, :boolean
    field :controls, :boolean
    field :fullscreen, :boolean
    field :looping, :boolean
    field :mute, :boolean
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [
      :title,
      :subtitle,
      :video_url,
      :autoplay,
      :controls,
      :fullscreen,
      :looping,
      :mute
    ])
    |> validate_required([])
  end
end
