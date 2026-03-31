defmodule ScalesCms.Cms.CmsBlockTemplate do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_block_templates" do
    field :name, :string
    field :component_type, :string
    field :properties, :map
    field :locale, :string
    field :template_family_id, Ecto.UUID
    field :template_mode, Ecto.Enum, values: [:live, :snapshot], default: :live
    field :published_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cms_block_template, attrs) do
    cms_block_template
    |> cast(attrs, [
      :name,
      :component_type,
      :properties,
      :locale,
      :template_family_id,
      :template_mode,
      :published_at
    ])
    |> put_template_family_id()
    |> validate_required([:name, :component_type, :locale, :template_family_id, :template_mode])
    |> validate_template_mode_locked()
    |> unique_constraint([:template_family_id, :locale],
      name: :cms_block_templates_template_family_id_locale_index
    )
  end

  defp validate_template_mode_locked(changeset) do
    if get_field(changeset, :published_at) &&
         changed?(changeset, :template_mode) do
      add_error(changeset, :template_mode, "cannot be changed after publication")
    else
      changeset
    end
  end

  defp put_template_family_id(changeset) do
    case get_field(changeset, :template_family_id) do
      nil -> put_change(changeset, :template_family_id, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
