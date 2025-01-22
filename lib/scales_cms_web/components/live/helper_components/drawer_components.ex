defmodule ScalesCmsWeb.Components.HelperComponents.DrawerComponents do
  @moduledoc """
  A drawer preview for the component library
  """
  use ScalesCmsWeb, :live_component

  attr :description, :string
  attr :icon_type, :string
  attr :title, :string
  attr :published, :boolean

  def drawer_preview(assigns) do
    ~H"""
    <div class={"flex flex-row #{if !@published, do: "drag-handle cursor-move"}"}>
      <div class="mr-4 mt-[4px]">
        <.svg type={@icon_type} class="w-[40px] h-[30px]" />
      </div>

      <div class="grow">
        <p class="font-semibold">{@title}</p>
        <p class="text-gray-500">{@description}</p>
      </div>

      <.icon :if={!@published} name="hero-arrows-pointing-out" class="hero-arrow" />
    </div>
    """
  end
end
