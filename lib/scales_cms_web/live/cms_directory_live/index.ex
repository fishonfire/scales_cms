defmodule ScalesCmsWeb.CmsDirectoryLive.Index do
  use ScalesCmsWeb, :live_view

  alias ScalesCms.Cms.CmsDirectories
  alias ScalesCms.Cms.CmsPages
  alias ScalesCms.Cms.CmsDirectory

  alias ScalesCmsWeb.Components.LocaleSwitcher

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(locale: ScalesCms.Cms.Helpers.Locales.default_locale())
    |> assign(:cms_directories, [])
    |> assign(:cms_pages, [])
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Edit directory"))
    |> assign(:cms_directory, CmsDirectories.get_cms_directory!(id))
  end

  defp apply_action(socket, :new, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("New directory"))
    |> assign(:current_directory, nil)
    |> assign(:cms_directory, %CmsDirectory{
      cms_directory_id: id
    })
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New directory"))
    |> assign(:current_directory, nil)
    |> assign(:cms_directory, %CmsDirectory{})
  end

  defp apply_action(socket, :index, %{"id" => id} = params) do
    query = Map.get(params, "query", "")
    status = Map.get(params, "status", "")
    current_directory = CmsDirectories.get_cms_directory!(id)

    cms_directories =
      if query != "" do
        CmsDirectories.search_cms_directories_for_parent_id(id, query)
      else
        CmsDirectories.list_cms_directories_for_parent_id(id)
      end

    cms_pages = fetch_pages_for_directory(id, query, status)

    socket
    |> assign(:cms_directories, cms_directories)
    |> assign(:cms_pages, cms_pages)
    |> assign(:current_directory, current_directory)
    |> assign(:page_title, gettext("Directories"))
    |> assign(:cms_directory, nil)
    |> assign(:query, query)
    |> assign(:status, status)
  end

  defp apply_action(socket, :index, params) do
    query = Map.get(params, "query", "")
    status = Map.get(params, "status", "")

    cms_directories =
      if query != "" do
        CmsDirectories.search_cms_directories(query)
      else
        CmsDirectories.list_cms_directories()
      end

    cms_pages = fetch_pages(query, status)

    socket
    |> assign(:cms_directories, cms_directories)
    |> assign(:cms_pages, cms_pages)
    |> assign(:current_directory, nil)
    |> assign(:page_title, gettext("Directories"))
    |> assign(:cms_directory, nil)
    |> assign(:query, query)
    |> assign(:status, status)
  end

  defp fetch_pages_for_directory(directory_id, "", ""),
    do: CmsPages.list_pages_for_directory_id(directory_id)

  defp fetch_pages_for_directory(directory_id, "", status),
    do: CmsPages.list_pages_for_directory_id(directory_id, status)

  defp fetch_pages_for_directory(directory_id, query, ""),
    do: CmsPages.search_cms_pages_for_directory_id(directory_id, query)

  defp fetch_pages_for_directory(directory_id, query, status),
    do: CmsPages.search_cms_pages_for_directory_id(directory_id, query, status)

  defp fetch_pages("", ""), do: CmsPages.list_cms_pages()
  defp fetch_pages("", status), do: CmsPages.list_cms_pages(status)
  defp fetch_pages(query, ""), do: CmsPages.search_cms_pages(query)
  defp fetch_pages(query, status), do: CmsPages.search_cms_pages(query, status)

  @impl Phoenix.LiveView
  def handle_info({ScalesCmsWeb.CmsDirectoryLive.FormComponent, {:saved, cms_directory}}, socket) do
    cms_directories =
      if cms_directory.cms_directory_id != nil,
        do: CmsDirectories.list_cms_directories_for_parent_id(cms_directory.cms_directory_id),
        else: CmsDirectories.list_cms_directories()

    socket
    |> assign(
      :cms_directories,
      cms_directories
    )
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveView
  def handle_info({ScalesCmsWeb.Components.LocaleSwitcher, {:locale_switched, locale}}, socket) do
    socket
    |> assign(:locale, locale)
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    cms_directory = CmsDirectories.get_cms_directory!(id)
    {:ok, _} = CmsDirectories.delete_cms_directory(cms_directory)

    cms_directories =
      if cms_directory.cms_directory_id != nil,
        do: CmsDirectories.list_cms_directories_for_parent_id(cms_directory.cms_directory_id),
        else: CmsDirectories.list_cms_directories()

    socket
    |> assign(
      :cms_directories,
      cms_directories
    )
    |> then(&{:noreply, &1})
  rescue
    Ecto.ConstraintError ->
      {:noreply,
       socket
       |> put_flash(:error, "Directory not empty")}
  end

  def handle_event("delete-page", %{"id" => id}, socket) do
    ScalesCms.Cms.Flows.Pages.DeletePage.perform(id)

    cms_pages =
      if socket.assigns.current_directory != nil,
        do: CmsPages.list_pages_for_directory_id(socket.assigns.current_directory.id),
        else: CmsPages.list_cms_pages()

    socket
    |> assign(
      :cms_pages,
      cms_pages
    )
    |> then(&{:noreply, &1})
  rescue
    Ecto.ConstraintError ->
      {:noreply,
       socket
       |> put_flash(:error, "Page not empty")}
  end

  def handle_event("open-directory", %{"id" => id}, socket) do
    socket
    |> push_navigate(to: ~p"/cms/directories/#{id}")
    |> then(&{:noreply, &1})
  end

  def handle_event("open-directory", %{}, socket) do
    socket
    |> push_navigate(to: ~p"/cms/directories")
    |> then(&{:noreply, &1})
  end

  def handle_event("open-page", %{"id" => id}, %{assigns: %{locale: locale}} = socket) do
    pv = ScalesCms.Cms.Flows.Pages.FindCorrectVariant.perform(id, locale)

    socket
    |> push_navigate(to: ~p"/cms/page_builder/#{pv.id}")
    |> then(&{:noreply, &1})
  end

  def handle_event("search", %{"query" => query}, socket) do
    status = socket.assigns.status

    socket
    |> push_patch(to: build_filter_path(socket.assigns.current_directory, query, status))
    |> then(&{:noreply, &1})
  end

  def handle_event("filter_status", %{"status" => status}, socket) do
    query = socket.assigns.query

    socket
    |> push_patch(to: build_filter_path(socket.assigns.current_directory, query, status))
    |> then(&{:noreply, &1})
  end

  defp build_filter_path(current_directory, query, status) do
    base_path =
      if current_directory != nil,
        do: ~p"/cms/directories/#{current_directory.id}",
        else: ~p"/cms/directories"

    params =
      %{}
      |> maybe_add_param("query", query)
      |> maybe_add_param("status", status)

    if params == %{},
      do: base_path,
      else: base_path <> "?" <> URI.encode_query(params)
  end

  defp maybe_add_param(params, _key, ""), do: params
  defp maybe_add_param(params, _key, nil), do: params
  defp maybe_add_param(params, key, value), do: Map.put(params, key, value)

  def page_published?(cms_page), do: CmsPages.published?(cms_page)

  def get_new_directory_path(nil), do: ~p"/cms/directories/new"

  def get_new_directory_path(current_directory),
    do: ~p"/cms/directories/#{current_directory.id}/new"

  def get_new_page_path(nil), do: ~p"/cms/pages/new"

  def get_new_page_path(current_directory), do: ~p"/cms/pages/#{current_directory.id}/new"
end
