defmodule ScalesCmsWeb.Components.HelperComponents.DrawerComponents do
  @moduledoc """
  Shared drawer preview for the component library.
  Supports both regular components and template-backed insertables.
  """
  use ScalesCmsWeb, :live_component

  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :icon_type, :string, default: "cms_block"
  attr :published, :boolean, default: false

  def drawer_preview(assigns) do
    ~H"""
    <div class={"flex flex-row #{if !@published, do: "drag-handle cursor-move"}"}>
      <div class="mr-4 mt-[4px]">
        <.svg type={@icon_type} class="w-[40px] h-[30px]" />
      </div>

      <div class="grow min-w-0">
        <p class="truncate font-semibold">{@title}</p>

        <p :if={@description} class="text-xs text-gray-500">
          {@description}
        </p>
      </div>

      <.icon :if={!@published} name="hero-arrows-pointing-out" class="hero-arrow" />
    </div>
    """
  end
end
