defmodule GlorioCmsWeb.CmsPageVariantLive.FormComponent do
  use GlorioCmsWeb, :live_component

  alias GlorioCms.Cms.CmsPageVariants

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage cms_page_variant records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="cms_page_variant-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:published_at]} type="datetime-local" label="Published at" />
        <.input field={@form[:locale]} type="text" label="Locale" />
        <.input field={@form[:version]} type="number" label="Version" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Cms page variant</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{cms_page_variant: cms_page_variant} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(CmsPageVariants.change_cms_page_variant(cms_page_variant))
     end)}
  end

  @impl true
  def handle_event("validate", %{"cms_page_variant" => cms_page_variant_params}, socket) do
    changeset =
      CmsPageVariants.change_cms_page_variant(
        socket.assigns.cms_page_variant,
        cms_page_variant_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"cms_page_variant" => cms_page_variant_params}, socket) do
    save_cms_page_variant(socket, socket.assigns.action, cms_page_variant_params)
  end

  defp save_cms_page_variant(socket, :edit, cms_page_variant_params) do
    case CmsPageVariants.update_cms_page_variant(
           socket.assigns.cms_page_variant,
           cms_page_variant_params
         ) do
      {:ok, cms_page_variant} ->
        notify_parent({:saved, cms_page_variant})

        {:noreply,
         socket
         |> put_flash(:info, "Cms page variant updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_cms_page_variant(socket, :new, cms_page_variant_params) do
    case CmsPageVariants.create_cms_page_variant(cms_page_variant_params) do
      {:ok, cms_page_variant} ->
        notify_parent({:saved, cms_page_variant})

        {:noreply,
         socket
         |> put_flash(:info, "Cms page variant created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
