defmodule ScalesCmsWeb.Components.HelperComponents.DrawerComponents do
  @moduledoc """
  A drawer preview for the component library
  """
  use ScalesCmsWeb, :live_component

  attr :description, :string
  attr :icon_type, :string
  attr :title, :string

  def drawer_preview(assigns) do
    ~H"""
    <div class="flex flex-row">
      <div class="mr-4 mt-[4px]">
        <.svg type={@icon_type} class="w-[24px] h-[24px]" />
      </div>

      <div class="grow">
        <p class="font-bold">{@title}</p>
        <p class="text-gray-500">{@description}</p>
      </div>

      <div class="drag-handle">
        <.icon name="hero-arrows-pointing-out" class="w-[24px] h-[24px] cursor-pointer hero-arrow" />
      </div>
    </div>
    """
  end
end
