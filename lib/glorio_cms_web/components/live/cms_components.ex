defmodule GlorioCmsWeb.Components.CmsComponents do
  @component_list %{
    "header" => GlorioCmsWeb.Components.CmsComponents.Header,
    "test" => GlorioCmsWeb.Components.CmsComponents.Test
  }

  def get_components(), do: @component_list

  def get_component(key), do: Map.get(@component_list, key)
end
