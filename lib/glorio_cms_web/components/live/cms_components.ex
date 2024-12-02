defmodule GlorioCmsWeb.Components.CmsComponents do
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
end
