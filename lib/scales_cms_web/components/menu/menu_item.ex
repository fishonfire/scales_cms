defmodule ScalesCmsWeb.Components.MenuItem do
  @enforce_keys [:title, :icon, :route]
  defstruct [:title, :icon, :route]

  use ScalesCmsWeb, :live_component

  def render(assigns) do
    ~H"""
    """
  end
end