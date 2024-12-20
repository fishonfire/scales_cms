# Custom components
ScalesCMS offers the ability to create custom components that can be used both in the CMS editor and in the app.
This requires two stages, one is to create the component in your Phoenix application and two is to set this up in your React Native application.

## Creating a custom component in your Phoenix application
### The config
```elixir
config :scales_cms,
  custom_components: CmsDemoWeb.Components.CmsComponents.get_menu_items()
```

And the components are then set to:
```elixir
defmodule CmsDemoWeb.Components.CmsComponents do
  def get_menu_items() do
    %{
      "MyDemoComponent" => CmsDemoWeb.Components.CmsComponents.MyDemoComponent
    }
  end
end
```

### The component config
```elixir
defmodule CmsDemoWeb.Components.CmsComponents.MyDemoComponent do
  @moduledoc false
  use CmsDemoWeb, :live_component

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: gettext("My demo component"), # displayed in the drawer
    category: "Content", # anything goes here
    description: gettext("Small or lang text like title or description"),
    icon_type: "cms_rich_text",
    preview_module: CmsDemoWeb.Components.CmsComponents.MyDemoComponent.Editor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
```

### The editor
```elixir
defmodule CmsDemoWeb.Components.CmsComponents.MyDemoComponent.Editor do
  @moduledoc false
  alias CmsDemoWeb.Components.CmsComponents.MyDemoComponent.Properties

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        MdProperties.changeset(
          struct(
            MdProperties,
            assigns.block.properties
          ),
          assigns.block.properties
        )
      )

    socket
    |> assign(assigns)
    |> assign(form: form)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event("store-properties", %{"md_properties" => properties}, socket) do
    with _block <-
            ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
              socket.assigns.block,
              %{properties: properties}
            ) do
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.live_component id={"head-#{@block.id}"} module={BlockWrapper} block={@block} phx-submit="store-content">
        <.simple_form for={@form} phx-change="store-properties" phx-target={@myself}>
          <.input type="text" field={@form[:content]} id={"markdown-#{@block.id}-content"} />

          <.submit>Submit</.submit>
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end
```

### The schema
The schema provides an Ecto.Schema that you can back your data structure against.
This gets stored as a JSONB.
```elixir
defmodule CmsDemoWeb.Components.CmsComponents.MyDemoComponent.Properties do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :content, :string
  end

  @doc false
  def changeset(properties, attrs) do
    properties
    |> cast(attrs, [:content])
    |> validate_required([])
  end
end
```



### Icon types
TBD
