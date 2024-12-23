defmodule ScalesCmsWeb.Components.LocaleSwitcher do
  @moduledoc """
  A locale switcher component, that provides a PubSub feature throughout the whole
  application so they can tag along with locale changes
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Constants.Topics
  alias ScalesCms.Cms.Helpers.Locales

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, locale: Locales.default_locale())}
  end

  attr :class, :string, default: nil

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id="locale-switcher" phx-hook="LocalLocaleStorage" phx-target={@myself} class={@class}>
      <form>
        <select
          name="locale"
          id="locale"
          phx-change="switch-locale"
          phx-target={@myself}
          class="border-[1px] rounded py-[12px] px-[16px] text-sm"
        >
          <%= for %{code: code, name: name} <- Locales.all() do %>
            <option value={code} selected={code == @locale}>{name}</option>
          <% end %>
        </select>
      </form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("got-locale", %{"locale" => locale}, socket) do
    Phoenix.PubSub.broadcast(
      ScalesCms.PubSub,
      Topics.get_set_locale_topic(),
      {:set_locale, locale}
    )

    {:noreply,
     socket
     |> assign(locale: locale)}
  end

  def handle_event("switch-locale", %{"locale" => locale}, socket) do
    Phoenix.PubSub.broadcast(
      ScalesCms.PubSub,
      Topics.get_set_locale_topic(),
      {:set_locale, locale}
    )

    socket
    |> push_event("set-locale", %{locale: locale})
    |> assign(locale: locale)
    |> then(&{:noreply, &1})
  end
end
