defmodule ScalesCmsWeb.CmsDirectoryLive.FormComponent do
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Cms.CmsDirectories

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>{gettext("Create a new directory")}</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="cms_directory-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:cms_directory_id]} type="hidden" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Cms directory</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{cms_directory: cms_directory} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(CmsDirectories.change_cms_directory(cms_directory))
     end)}
  end

  @impl true
  def handle_event("validate", %{"cms_directory" => cms_directory_params}, socket) do
    changeset =
      CmsDirectories.change_cms_directory(socket.assigns.cms_directory, cms_directory_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"cms_directory" => cms_directory_params}, socket) do
    save_cms_directory(socket, socket.assigns.action, cms_directory_params)
  end

  defp save_cms_directory(socket, :edit, cms_directory_params) do
    cms_directory_params =
      Map.put(
        cms_directory_params,
        "slug",
        ScalesCms.Cms.Helpers.Slugify.slugify(cms_directory_params["title"])
      )

    case CmsDirectories.update_cms_directory(socket.assigns.cms_directory, cms_directory_params) do
      {:ok, cms_directory} ->
        notify_parent({:saved, cms_directory})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Directory updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_cms_directory(socket, :new, cms_directory_params) do
    cms_directory_params =
      Map.put(
        cms_directory_params,
        "slug",
        ScalesCms.Cms.Helpers.Slugify.slugify(cms_directory_params["title"])
      )

    case CmsDirectories.create_cms_directory(cms_directory_params) do
      {:ok, cms_directory} ->
        notify_parent({:saved, cms_directory})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Directory created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
