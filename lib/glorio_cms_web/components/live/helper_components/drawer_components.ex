defmodule GlorioCmsWeb.Components.HelperComponents.DrawerComponents do
  use GlorioCmsWeb, :live_component

  attr :description, :string
  attr :icon_type, :string
  attr :title, :string

  def drawer_preview(assigns) do
    ~H"""
    <div class="flex flex-row">
      <div class="icon mr-4">
        <.svg type={@icon_type} class="w-[24px] h-[24px]" />
      </div>

      <div class="grow">
        <p>{@title}</p>
        <p>{@description}</p>
      </div>

      <div class="drag-handle">
        <.svg type="drag_handle" class="w-[24px] h-[24px]" />
      </div>
    </div>
    """
  end
end
