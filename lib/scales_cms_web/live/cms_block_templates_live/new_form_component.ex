defmodule ScalesCmsWeb.CmsBlockTemplatesLive.NewFormComponent do
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Cms.CmsBlockTemplates
  alias ScalesCmsWeb.Components.CmsComponents

  @impl Phoenix.LiveComponent
  def mount(socket) do
    socket
    |> assign(
      :component_type_options,
      CmsComponents.get_components()
      |> Enum.map(fn {key, _component} -> key end)
    )
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {gettext("Block template")}
        <:subtitle>{gettext("Create a new block template")}</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id={"cms_block_template-form-#{@id}"}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:name]}
          type="text"
          placeholder="Block name"
          id="cms_block_template-name"
        />

        <.input
          field={@form[:locale]}
          type="hidden"
          value={@locale}
        />

        <.label for="cms_block_template_component_type">
          {gettext("Component type")}
        </.label>

        <.input
          field={@form[:component_type]}
          type="select"
          options={@component_type_options}
        />

        <:actions>
          <.button phx-disable-with="Saving..." class="btn-primary">
            {gettext("Save block template")}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{cms_block_template: cms_block_template} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(CmsBlockTemplates.change_cms_block_template(cms_block_template)))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"cms_block_template" => cms_block_template_params}, socket) do
    changeset =
      CmsBlockTemplates.change_cms_block_template(
        socket.assigns.cms_block_template,
        cms_block_template_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"cms_block_template" => cms_block_template_params}, socket) do
    case CmsBlockTemplates.create_cms_block_template(cms_block_template_params) do
      {:ok, _cms_block_template} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Block template created successfully"))
         |> push_navigate(to: ~p"/cms/block_templates")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
