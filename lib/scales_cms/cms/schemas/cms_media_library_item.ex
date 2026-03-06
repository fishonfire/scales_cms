defmodule ScalesCms.Cms.CmsMediaLibraryItem do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @type_values ~w(video image lottie)

  schema "cms_media_library" do
    field :name, :string
    field :type, :string
    field :url, :string
    field :deleted_at, :naive_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(media_library_item, attrs) do
    media_library_item
    |> cast(attrs, [:name, :type, :url, :deleted_at])
    |> validate_required([:name, :type, :url])
    |> validate_inclusion(:type, @type_values)
  end

  def type_values, do: @type_values
end
