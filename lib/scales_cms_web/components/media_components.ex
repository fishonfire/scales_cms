defmodule ScalesCmsWeb.MediaComponents do
  @moduledoc """
  Provides custom made Media components.
  """
  use Phoenix.Component

  use Gettext,
    backend: ScalesCmsWeb.Gettext

  import ScalesCmsWeb.CoreComponents
  alias ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryUtils

  attr :item, :map, required: true
  attr :target, :any, default: nil
  attr :with_delete, :boolean, default: false
  attr :show_date, :boolean, default: false

  def media_preview(assigns) do
    ~H"""
    <div class="group relative bg-gray-200 rounded-lg overflow-hidden p-2">
      <div
        id={"media-preview-#{@item.id}"}
        phx-hook="MediaPreview"
        data-type={@item.type}
        class="relative w-full aspect-[3/2] bg-gray-200 rounded-lg overflow-hidden"
      >
        <div
          data-placeholder
          class="absolute inset-0 animate-pulse flex items-center justify-center animate-fade-in bg-gradient-to-br from-gray-300 to-gray-400"
        >
          <%= case @item.type do %>
            <% "image" -> %>
              <.icon name="hero-photo" class="h-8 w-8 text-gray-500" />
            <% "video" -> %>
              <.icon name="hero-film" class="h-8 w-8 text-gray-500" />
            <% "lottie" -> %>
              <.icon name="hero-sparkles" class="h-8 w-8 text-gray-500" />
            <% _ -> %>
              <.icon name="hero-photo" class="h-8 w-8 text-gray-500" />
          <% end %>
        </div>

        <%= case @item.type do %>
          <% "image" -> %>
            <div class="absolute inset-0 media-preview-el">
              <img
                id={"image-library-#{@item.id}"}
                data-media-el
                data-loaded="false"
                src={@item.display_url}
                phx-update="ignore"
                class="w-full h-full object-cover"
                alt={@item.name}
              />
            </div>
          <% "video" -> %>
            <div class="absolute inset-0 media-preview-el">
              <video
                id={"video-player-#{@item.id}"}
                data-media-el
                data-playable
                data-loaded="false"
                preload="metadata"
                muted
                playsinline
                phx-update="ignore"
                class="absolute inset-0 w-full h-full object-cover"
              >
                <source src={@item.display_url} />
              </video>

              <div class="absolute inset-0 z-10 flex items-center justify-center">
                <button
                  type="button"
                  data-play-button
                  aria-label={gettext("Play video")}
                  class="flex h-14 w-14 items-center justify-center rounded-full bg-white/70 shadow-lg hover:bg-white transition-colors duration-200  opacity-0 cursor-pointer"
                >
                  <.icon name="hero-play-solid" class="ml-0.5 h-7 w-7 text-gray-900" />
                </button>
              </div>
            </div>
          <% "lottie" -> %>
            <div class="absolute inset-0 media-preview-el">
              <dotlottie-player
                id={"lottie-player-#{@item.id}"}
                data-media-el
                data-playable
                data-loaded="false"
                src={@item.display_url}
                background="white"
                speed="1"
                class="h-full w-full object-cover"
                direction="1"
                playMode="normal"
                loop
                phx-update="ignore"
                autoplay={false}
              >
              </dotlottie-player>

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
          <% _ -> %>
            <div class="absolute inset-0 bg-gradient-to-br from-gray-300 to-gray-400 flex items-center justify-center">
              <.icon name="hero-photo" class="h-8 w-8 text-gray-400" />
            </div>
        <% end %>

        <button
          :if={@with_delete}
          type="button"
          phx-click="show_delete_modal"
          phx-target={@target}
          phx-value-id={@item.id}
          class="absolute top-2 right-2 z-20 h-[24px] w-[24px] rounded bg-white text-red-500 transition-colors hover:bg-gray-200"
        >
          <.icon name="hero-trash" class="h-[14px] w-[12px]" />
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
