defmodule GlorioCmsWeb.CmsPageLive.Show do
  alias GlorioCms.Cms.CmsPageVariants
  use GlorioCmsWeb, :live_view

  alias GlorioCms.Cms.CmsPages
  alias GlorioCmsWeb.Components.LocaleSwitcher
  alias GlorioCms.Constants.Topics

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(GlorioCms.PubSub, Topics.get_set_locale_topic())

    {:ok, assign(socket, locale: GlorioCms.Cms.Helpers.Locales.default_locale())}
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
  def handle_info(
        {:set_locale, locale},
        socket
      ) do
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
