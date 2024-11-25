defmodule GlorioCmsWeb.CmsPageLive.FormComponent do
  use GlorioCmsWeb, :live_component

  alias GlorioCms.Cms.CmsPages

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage cms_page records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="cms_page-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:deleted_at]} type="datetime-local" label="Deleted at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Cms page</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{cms_page: cms_page} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(CmsPages.change_cms_page(cms_page))
     end)}
  end

  @impl true
  def handle_event("validate", %{"cms_page" => cms_page_params}, socket) do
    changeset = CmsPages.change_cms_page(socket.assigns.cms_page, cms_page_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"cms_page" => cms_page_params}, socket) do
    save_cms_page(socket, socket.assigns.action, cms_page_params)
  end

  defp save_cms_page(socket, :edit, cms_page_params) do
    case CmsPages.update_cms_page(socket.assigns.cms_page, cms_page_params) do
      {:ok, cms_page} ->
        notify_parent({:saved, cms_page})

        {:noreply,
         socket
         |> put_flash(:info, "Cms page updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_cms_page(socket, :new, cms_page_params) do
    case CmsPages.create_cms_page(cms_page_params) do
      {:ok, cms_page} ->
        notify_parent({:saved, cms_page})

        {:noreply,
         socket
         |> put_flash(:info, "Cms page created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
