defmodule ScalesCmsWeb.Components.MenuItem do
  @moduledoc false
  @enforce_keys [:title, :icon, :route]
  defstruct [:title, :icon, :route, :alternative_routes]

  use ScalesCmsWeb, :live_component

  def render(assigns) do
    ~H"""
    """
  end
end
