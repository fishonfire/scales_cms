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
    |> stream(:cms_directories, [])
    |> stream(:cms_pages, [])
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cms directory")
    |> assign(:cms_directory, CmsDirectories.get_cms_directory!(id))
  end

  defp apply_action(socket, :new, %{"id" => id}) do
    socket
    |> assign(:page_title, "New Cms directory")
    |> assign(:current_directory, nil)
    |> assign(:cms_directory, %CmsDirectory{
      cms_directory_id: id
    })
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cms directory")
    |> assign(:current_directory, nil)
    |> assign(:cms_directory, %CmsDirectory{})
  end

  defp apply_action(socket, :index, %{"id" => id}) do
    socket
    |> stream(
      :cms_directories,
      CmsDirectories.list_cms_directories_for_parent_id(id),
      reset: true
    )
    |> stream(
      :cms_pages,
      CmsPages.list_pages_for_directory_id(id),
      reset: true
    )
    |> assign(:current_directory, CmsDirectories.get_cms_directory!(id))
    |> assign(:page_title, "Listing Cms directories")
    |> assign(:cms_directory, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> stream(
      :cms_directories,
      CmsDirectories.list_cms_directories(),
      reset: true
    )
    |> stream(
      :cms_pages,
      CmsPages.list_cms_pages(),
      reset: true
    )
    |> assign(:current_directory, nil)
    |> assign(:page_title, "Listing Cms directories")
    |> assign(:cms_directory, nil)
  end

  @impl Phoenix.LiveView
  def handle_info({GlorioCmsWeb.CmsDirectoryLive.FormComponent, {:saved, cms_directory}}, socket) do
    {:noreply, stream_insert(socket, :cms_directories, cms_directory)}
  end

  @impl Phoenix.LiveView
  def handle_info(
        {:set_locale, locale},
        socket
      ) do
    {:noreply, assign(socket, locale: locale)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    cms_directory = CmsDirectories.get_cms_directory!(id)
    {:ok, _} = CmsDirectories.delete_cms_directory(cms_directory)

    {:noreply, stream_delete(socket, :cms_directories, cms_directory)}
  rescue
    Ecto.ConstraintError ->
      {:noreply,
       socket
       |> put_flash(:error, "Directory not empty")}
  end
end
