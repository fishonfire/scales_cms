defmodule ScalesCmsWeb.CmsPageLive.Show do
  alias ScalesCms.Cms.CmsPageVariants
  use ScalesCmsWeb, :live_view

  alias ScalesCms.Cms.CmsPages
  alias ScalesCmsWeb.Components.LocaleSwitcher

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, locale: ScalesCms.Cms.Helpers.Locales.default_locale())}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _, socket) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:cms_page, CmsPages.get_cms_page!(id))
    |> stream(
      :variants,
      CmsPageVariants.list_cms_page_variants_for_page_and_locale(id, socket.assigns.locale),
      reset: true
    )
    |> maybe_open_modal(socket.assigns.live_action)
    |> then(&{:noreply, &1})
  end

  defp page_title(:show), do: gettext("Show page")
  defp page_title(:edit), do: gettext("Edit page")

  defp maybe_open_modal(socket, :edit), do: open_modal(socket, "cms_page-modal")
  defp maybe_open_modal(socket, _), do: socket

  @impl Phoenix.LiveView
  def handle_info({ScalesCmsWeb.CmsPageLive.FormComponent, {:saved, cms_page}}, socket) do
    socket
    |> assign(:cms_page, cms_page)
    |> close_modal("cms_page-modal")
    |> then(&{:noreply, &1})
  end

  def handle_info({ScalesCmsWeb.Components.LocaleSwitcher, {:locale_switched, locale}}, socket) do
    socket
    |> assign(:locale, locale)
    |> stream(
      :variants,
      CmsPageVariants.list_cms_page_variants_for_page_and_locale(
        socket.assigns.cms_page.id,
        locale
      ),
      reset: true
    )
    |> then(&{:noreply, &1})
  end
end
