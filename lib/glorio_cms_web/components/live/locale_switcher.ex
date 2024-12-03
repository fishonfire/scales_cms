defmodule GlorioCmsWeb.Components.LocaleSwitcher do
  use GlorioCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, locale: default_locale())}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id="locale-switcher" phx-hook="LocalLocaleStorage" phx-target={@myself}>
      <form>
        <select name="locale" id="locale" phx-change="switch-locale" phx-target={@myself}>
          <%= for %{code: code, name: name} <- locales() do %>
            <option value={code} selected={code == @locale}><%= name %></option>
          <% end %>
        </select>
      </form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("got-locale", params, socket) do
    {:noreply,
     socket
     |> assign(locale: params["locale"])}
  end

  def handle_event("switch-locale", %{"locale" => locale}, socket) do
    socket
    |> push_event("set-locale", %{locale: locale})
    |> assign(locale: locale)
    |> then(&{:noreply, &1})
  end

  defp locales() do
    [
      %{code: "nl-NL", name: "Dutch"},
      %{code: "en-US", name: "English"},
      %{code: "fr-FR", name: "Français"}
    ]
  end

  defp default_locale() do
    Application.get_env(:glorio_cms, :cms)[:default_locale] || "en-US"
  end
end
