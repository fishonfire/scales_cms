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
    |> assign(:cms_page, CmsPages.get_cms_page!(id))
    |> stream(
      :variants,
      CmsPageVariants.list_cms_page_variants_for_page_and_locale(id, socket.assigns.locale),
      reset: true
    )
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveView
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
