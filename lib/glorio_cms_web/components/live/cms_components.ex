defmodule GlorioCmsWeb.Components.CmsComponents do
  @moduledoc """
  An index of all components
  """
  alias GlorioCmsWeb.Components.CmsComponents.{
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

  def get_components(), do: @component_list

  def get_component(key), do: Map.get(@component_list, key)

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
