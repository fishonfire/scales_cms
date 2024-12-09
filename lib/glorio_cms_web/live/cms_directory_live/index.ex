defmodule GlorioCmsWeb.CmsDirectoryLive.Index do
  use GlorioCmsWeb, :live_view

  alias GlorioCms.Cms.CmsDirectories
  alias GlorioCms.Cms.CmsPages
  alias GlorioCms.Cms.CmsDirectory

  alias GlorioCmsWeb.Components.LocaleSwitcher
  alias GlorioCms.Constants.Topics

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(GlorioCms.PubSub, Topics.get_set_locale_topic())

    socket
    |> assign(locale: GlorioCms.Cms.Helpers.Locales.default_locale())
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

  defp apply_action(socket, :index, %{"id" => id}) do
    socket
    |> assign(
      :cms_directories,
      CmsDirectories.list_cms_directories_for_parent_id(id)
    )
    |> assign(
      :cms_pages,
      CmsPages.list_pages_for_directory_id(id)
    )
    |> assign(:current_directory, CmsDirectories.get_cms_directory!(id))
    |> assign(:page_title, gettext("Directories"))
    |> assign(:cms_directory, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(
      :cms_directories,
      CmsDirectories.list_cms_directories()
    )
    |> assign(
      :cms_pages,
      CmsPages.list_cms_pages()
    )
    |> assign(:current_directory, nil)
    |> assign(:page_title, gettext("Directories"))
    |> assign(:cms_directory, nil)
  end

  @impl Phoenix.LiveView
  def handle_info({GlorioCmsWeb.CmsDirectoryLive.FormComponent, {:saved, cms_directory}}, socket) do
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
  def handle_info(
        {:set_locale, locale},
        socket
      ) do
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
    cms_page = CmsPages.get_cms_page!(id)
    {:ok, _} = CmsPages.delete_cms_page(cms_page)

    cms_pages =
      if cms_page.cms_directory_id != nil,
        do: CmsPages.list_pages_for_directory_id(cms_page.cms_directory_id),
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
       |> put_flash(:error, "Directory not empty")}
  end

  def handle_event("open-directory", %{"id" => id}, socket) do
    socket
    |> push_navigate(to: ~p"/cms/cms_directories/#{id}")
    |> then(&{:noreply, &1})
  end

  def handle_event("open-page", %{"id" => id}, %{assigns: %{locale: locale}} = socket) do
    pv = GlorioCms.Cms.Flows.Pages.FindCorrectVariant.perform(id, locale)

    socket
    |> push_navigate(to: ~p"/cms/cms_page_builder/#{pv.id}")
    |> then(&{:noreply, &1})
  end

  def get_new_directory_path(nil), do: ~p"/cms/cms_directories/new"

  def get_new_directory_path(current_directory),
    do: ~p"/cms/cms_directories/#{current_directory.id}/new"

  def get_new_page_path(nil), do: ~p"/cms/cms_pages/new"

  def get_new_page_path(current_directory), do: ~p"/cms/cms_pages/#{current_directory.id}/new"
end
