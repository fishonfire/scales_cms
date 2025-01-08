defmodule ScalesCmsWeb.Components.CmsComponents do
  @moduledoc """
  An index of all components
  """
  alias ScalesCmsWeb.Components.CmsComponents.{
    Header,
    Dev,
    Md,
    Image,
    CTAButton,
    Button,
    ImageButton
  }

  @component_list %{
    "header" => Header,
    "dev" => Dev,
    "test" => Dev,
    "md" => Md,
    "image" => Image,
    "cta_button" => CTAButton,
    "button" => Button,
    "image_button" => ImageButton
  }

  def get_components(), do: Map.merge(@component_list, get_custom_components())

  def get_custom_components(), do: Application.get_env(:scales_cms, :custom_components, %{})

  def get_component(key), do: Map.get(get_components(), key)

  def get_categories() do
    get_components()
    |> Enum.map(fn {_key, component} -> component.category() end)
    |> MapSet.new()
    |> Enum.to_list()
  end

  def get_components_for_category("All"), do: get_components()

  def get_components_for_category(category) do
    get_components()
    |> Enum.filter(fn {_key, component} ->
      component.category() == category
    end)
  end
end
