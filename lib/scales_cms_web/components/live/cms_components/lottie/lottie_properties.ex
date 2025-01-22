defmodule ScalesCmsWeb.Components.CmsComponents.Lottie.LottieProperties do
  @moduledoc """
  The lottie component schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :title, :string
    field :subtitle, :string
    field :lottie_url, :string
    field :autoplay, :boolean
    field :looping, :boolean
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [
      :title,
      :subtitle,
      :lottie_url,
      :autoplay,
      :looping
    ])
    |> validate_required([])
  end
end
