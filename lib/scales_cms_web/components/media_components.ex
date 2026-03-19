defmodule ScalesCmsWeb.MediaComponents do
  @moduledoc """
  Provides custom made Media components.
  """
  use Phoenix.Component

  use Gettext,
    backend: ScalesCmsWeb.Gettext

  import ScalesCmsWeb.CoreComponents
  alias ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryUtils

  attr :id, :string, required: true
  attr :item, :map, required: true
  attr :target, :any, default: nil
  attr :with_context_button, :boolean, default: false
  attr :show_date, :boolean, default: false
  attr :keep_aspect, :boolean, default: false

  def media_preview(%{item: %{type: "image"}} = assigns) do
    ~H"""
    <div
      class="group relative bg-gray-200 rounded-lg overflow-hidden p-2"
      id={"media-item-#{@id}"}
      phx-hook="ContextMenu"
      data-id={@item.id}
      data-type="media"
    >
      <div
        id={"media-preview-#{@id}"}
        phx-hook="ImagePreview"
        data-type={@item.type}
        class="relative w-full aspect-[3/2] bg-gray-200 rounded-lg overflow-hidden"
        phx-update="ignore"
      >
        <div
          data-placeholder
          class="absolute inset-0 animate-pulse flex items-center justify-center animate-fade-in bg-gradient-to-br from-gray-300 to-gray-400"
        >
          <.icon name="hero-photo" class="h-8 w-8 text-gray-500" />
        </div>

        <div class="absolute inset-0 media-preview-el">
          <img
            id={"image-library-#{@id}"}
            data-media-el
            data-loaded="false"
            src={@item.display_url}
            phx-update="ignore"
            class={["w-full h-full", if(@keep_aspect, do: "object-contain", else: "object-cover")]}
            alt={@item.name}
          />
        </div>

        <button
          :if={@with_context_button}
          phx-hook="ContextMenuButton"
          id={"context-menu-btn-#{@id}"}
          data-type="media"
          data-id={@item.id}
          class="absolute h-[24px] w-[24px] top-2 right-2 bg-white hover:bg-gray-200 rounded text-primary transition-colors"
        >
          <.icon name="hero-wrench-screwdriver" class="h-[14px] w-[12px]" />
        </button>

        <div class="absolute bottom-2 left-2 z-20">
          <span class={"px-2 py-0.5 text-xs font-medium rounded #{type_badge_class(@item.type)}"}>
            {@item.type}
          </span>
        </div>
      </div>

      <div class="mt-2">
        <p class="truncate text-xs text-gray-900" title={@item.name}>
          {@item.name}
        </p>
        <p :if={@show_date} class="truncate text-xs text-gray-500">
          {Calendar.strftime(@item.inserted_at, "%d-%m-%Y")}
        </p>
      </div>
    </div>
    """
  end

  def media_preview(%{item: %{type: "video"}} = assigns) do
    ~H"""
    <div
      class="group relative bg-gray-200 rounded-lg overflow-hidden p-2"
      id={"media-item-#{@id}"}
      phx-hook="ContextMenu"
      data-id={@item.id}
      data-type="media"
    >
      <div
        id={"media-preview-#{@id}"}
        phx-hook="VideoPreview"
        data-type={@item.type}
        class="relative w-full aspect-[3/2] bg-gray-200 rounded-lg overflow-hidden"
        phx-update="ignore"
      >
        <div
          data-placeholder
          class="absolute inset-0 animate-pulse flex items-center justify-center animate-fade-in bg-gradient-to-br from-gray-300 to-gray-400"
        >
          <.icon name="hero-film" class="h-8 w-8 text-gray-500" />
        </div>

        <div class="absolute inset-0 media-preview-el">
          <video
            id={"video-player-#{@id}"}
            data-media-el
            data-playable
            data-loaded="false"
            preload="metadata"
            muted
            playsinline
            phx-update="ignore"
            class={[
              "absolute inset-0 w-full h-full",
              if(@keep_aspect, do: "object-contain", else: "object-cover")
            ]}
          >
            <source src={@item.display_url} />
          </video>

          <div class="absolute inset-0 z-10 flex items-center justify-center">
            <button
              type="button"
              data-play-button
              aria-label={gettext("Play video")}
              class="flex h-14 w-14 items-center justify-center rounded-full bg-white/70 shadow-lg hover:bg-white transition-colors duration-200 opacity-0 cursor-pointer"
            >
              <.icon name="hero-play-solid" class="ml-0.5 h-7 w-7 text-gray-900" />
            </button>
          </div>
        </div>

        <button
          :if={@with_context_button}
          phx-hook="ContextMenuButton"
          id={"context-menu-btn-#{@id}"}
          data-type="media"
          data-id={@item.id}
          class="absolute h-[24px] w-[24px] top-2 right-2 bg-white hover:bg-gray-200 rounded text-primary transition-colors"
        >
          <.icon name="hero-wrench-screwdriver" class="h-[14px] w-[12px]" />
        </button>

        <div class="absolute bottom-2 left-2 z-20">
          <span class={"px-2 py-0.5 text-xs font-medium rounded #{type_badge_class(@item.type)}"}>
            {@item.type}
          </span>
        </div>
      </div>

      <div class="mt-2">
        <p class="truncate text-xs text-gray-900" title={@item.name}>
          {@item.name}
        </p>
        <p :if={@show_date} class="truncate text-xs text-gray-500">
          {Calendar.strftime(@item.inserted_at, "%d-%m-%Y")}
        </p>
      </div>
    </div>
    """
  end

  def media_preview(%{item: %{type: "lottie"}} = assigns) do
    ~H"""
    <div
      class="group relative bg-gray-200 rounded-lg overflow-hidden p-2"
      id={"media-item-#{@id}"}
      phx-hook="ContextMenu"
      data-id={@item.id}
      data-type="media"
    >
      <div
        id={"media-preview-#{@id}"}
        phx-hook="LottiePreview"
        data-type={@item.type}
        class="relative w-full aspect-[3/2] bg-gray-200 rounded-lg overflow-hidden"
        phx-update="ignore"
      >
        <div
          data-placeholder
          class="absolute inset-0 animate-pulse flex items-center justify-center animate-fade-in bg-gradient-to-br from-gray-300 to-gray-400"
        >
          <.icon name="hero-sparkles" class="h-8 w-8 text-gray-500" />
        </div>

        <div class="absolute inset-0 media-preview-el">
          <dotlottie-wc
            id={"lottie-player-#{@id}"}
            data-media-el
            data-playable
            data-loaded="false"
            src={@item.display_url}
            background="white"
            speed="1"
            class={["h-full w-full", if(@keep_aspect, do: "object-contain", else: "object-cover")]}
            direction="1"
            playMode="normal"
            loop
            phx-update="ignore"
            autoplay={false}
          >
          </dotlottie-wc>

          <div class="absolute inset-0 z-10 flex items-center justify-center">
            <button
              type="button"
              data-play-button
              aria-label={gettext("Play animation")}
              class="flex h-14 w-14 items-center justify-center rounded-full bg-white/70 shadow-lg hover:bg-white transition-colors duration-200 opacity-0 cursor-pointer"
            >
              <.icon name="hero-play-solid" class="ml-0.5 h-7 w-7 text-gray-900" />
            </button>
          </div>
        </div>

        <button
          :if={@with_context_button}
          phx-hook="ContextMenuButton"
          id={"context-menu-btn-#{@id}"}
          data-type="media"
          data-id={@item.id}
          class="absolute h-[24px] w-[24px] top-2 right-2 bg-white hover:bg-gray-200 rounded text-primary transition-colors"
        >
          <.icon name="hero-wrench-screwdriver" class="h-[14px] w-[12px]" />
        </button>

        <div class="absolute bottom-2 left-2 z-20">
          <span class={"px-2 py-0.5 text-xs font-medium rounded #{type_badge_class(@item.type)}"}>
            {@item.type}
          </span>
        </div>
      </div>

      <div class="mt-2">
        <p class="truncate text-xs text-gray-900" title={@item.name}>
          {@item.name}
        </p>
        <p :if={@show_date} class="truncate text-xs text-gray-500">
          {Calendar.strftime(@item.inserted_at, "%d-%m-%Y")}
        </p>
      </div>
    </div>
    """
  end

  def media_preview(assigns) do
    ~H"""
    <div class="group relative bg-gray-200 rounded-lg overflow-hidden p-2">
      <div
        id={"media-preview-#{@id}"}
        data-type={@item.type}
        class="relative w-full aspect-[3/2] bg-gray-200 rounded-lg overflow-hidden"
      >
        <div class="absolute inset-0 bg-gradient-to-br from-gray-300 to-gray-400 flex items-center justify-center">
          <.icon name="hero-cross" class="h-8 w-8 text-gray-400" />
        </div>

        <button
          :if={@with_context_button}
          phx-hook="ContextMenuButton"
          id={"context-menu-btn-#{@id}"}
          data-type="media"
          data-id={@item.id}
          class="absolute h-[24px] w-[24px] top-2 right-2 bg-white hover:bg-gray-200 rounded text-primary transition-colors"
        >
          <.icon name="hero-wrench-screwdriver" class="h-[14px] w-[12px]" />
        </button>

        <div class="absolute bottom-2 left-2 z-20">
          <span class={"px-2 py-0.5 text-xs font-medium rounded #{type_badge_class(@item.type)}"}>
            {@item.type}
          </span>
        </div>
      </div>

      <div class="mt-2">
        <p class="truncate text-xs text-gray-900" title={@item.name}>
          {@item.name}
        </p>
        <p :if={@show_date} class="truncate text-xs text-gray-500">
          {Calendar.strftime(@item.inserted_at, "%d-%m-%Y")}
        </p>
      </div>
    </div>
    """
  end

  defdelegate type_badge_class(type), to: MediaLibraryUtils
end
