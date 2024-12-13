defmodule ScalesCmsWeb.Components.CmsComponents do
  @moduledoc """
  An index of all components
  """
  alias ScalesCmsWeb.Components.CmsComponents.{
    Header,
    Test,
    Md,
    Image
  }

  @component_list %{
    "header" => Header,
    "test" => Test,
    "md" => Md,
    "image" => Image
  }

  def get_components(), do: Map.merge(@component_list, get_custom_components())

  def get_custom_components(), do: Application.get_env(:scales_cms, :custom_components, %{})

  def get_component(key), do: Map.get(get_components(), key)

  def get_categories() do
    @component_list
    |> Enum.map(fn {_key, component} -> component.category() end)
    |> MapSet.new()
    |> Enum.to_list()
  end

  def get_components_for_category("All"), do: @component_list

  def get_components_for_category(category) do
    @component_list
    |> Enum.filter(fn {_key, component} ->
      component.category() == category
    end)
  end
end
