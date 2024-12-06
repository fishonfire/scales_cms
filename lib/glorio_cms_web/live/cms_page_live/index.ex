defmodule GlorioCmsWeb.CmsPageLive.Index do
  use GlorioCmsWeb, :live_view

  alias GlorioCms.Cms.CmsPages
  alias GlorioCms.Cms.CmsPage

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :cms_pages, CmsPages.list_cms_pages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Edit page"))
    |> assign(:cms_page, CmsPages.get_cms_page!(id))
  end

  defp apply_action(socket, :new, %{"id" => cms_directory_id})
       when is_binary(cms_directory_id) do
    socket
    |> assign(:page_title, gettext("New page"))
    |> assign(:cms_page, %CmsPage{cms_directory_id: cms_directory_id})
  end

  defp apply_action(socket, :new, _) do
    socket
    |> assign(:page_title, gettext("New page"))
    |> assign(:cms_page, %CmsPage{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("List pages"))
    |> assign(:cms_page, nil)
  end

  @impl true
  def handle_info({GlorioCmsWeb.CmsPageLive.FormComponent, {:saved, cms_page}}, socket) do
    url =
      if is_nil(cms_page.cms_directory_id),
        do: ~p"/cms/cms_directories",
        else: ~p"/cms/cms_directories/#{cms_page.cms_directory_id}"

    socket
    |> push_navigate(to: url)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    cms_page = CmsPages.get_cms_page!(id)
    {:ok, _} = CmsPages.delete_cms_page(cms_page)

    {:noreply, stream_delete(socket, :cms_pages, cms_page)}
  end
end
