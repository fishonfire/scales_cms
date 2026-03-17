# Setting up a context menu

What to add to your template, how to pass the right data, and how to render menu actions.

---

## What you need to do

To add a context menu for a new resource type:

1. Add the correct hook to the element
2. Provide `data-id` and `data-type`
3. Render menu actions inside `<.context_menu>`
4. Branch on `menu.type` to show the correct actions

---

## Right-click variant

Use `phx-hook="ContextMenu"` on the element that should open a menu on right-click.

### Example

```heex
<tr
  :for={cms_page <- @cms_pages}
  id={"cms_pages-#{cms_page.id}"}
  phx-hook="ContextMenu"
  data-id={cms_page.id}
  data-type="page"
>
  ...
</tr>
```

### When to use

Use this when the whole row or card should support a right-click menu.

---

## Left-click variant

Use `phx-hook="ContextMenuButton"` on a button or trigger element when you want a standard actions button.

### Example

```heex
<button
  type="button"
  phx-hook="ContextMenuButton"
  data-id={cms_page.id}
  data-type="page"
  class="inline-flex items-center justify-center rounded-md p-2 hover:bg-gray-100"
>
  <.icon name="hero-ellipsis-horizontal" class="icon-small" />
</button>
```

### Typical placement

You will usually place this in an actions column, toolbar, or card header.

```heex
<td class="text-right">
  <button
    type="button"
    phx-hook="ContextMenuButton"
    data-id={cms_page.id}
    data-type="page"
    class="inline-flex items-center justify-center rounded-md p-2 hover:bg-gray-100"
  >
    <.icon name="hero-ellipsis-horizontal" class="icon-small" />
  </button>
</td>
```

---

## Required data attributes

Every context menu trigger must provide these attributes:

```heex
data-id={resource.id}
data-type="page"
```

### `data-id`
The resource ID used by the menu actions.

### `data-type`
The type used to decide which menu items to render.

Examples:

```heex
data-type="page"
data-type="directory"
data-type="component"
```

---

## Rendering the menu

Render the shared context menu component somewhere on the bottom of a LiveView template:

```heex
<.context_menu context_menu={@context_menu}>
  <:menu_slots :let={menu}>
    <%= if menu.type == "directory" do %>
      <button
        type="button"
        phx-click="open-directory"
        phx-value-id={menu.id}
        class="block w-full px-4 py-2 text-left text-sm hover:bg-gray-100"
      >
        {gettext("Open")}
      </button>

      <button
        type="button"
        phx-click="edit-directory"
        phx-value-id={menu.id}
        class="block w-full px-4 py-2 text-left text-sm hover:bg-gray-100"
      >
        {gettext("Edit")}
      </button>

      <button
        type="button"
        phx-click="delete"
        phx-value-id={menu.id}
        class="block w-full px-4 py-2 text-left text-sm text-red-600 hover:bg-gray-100"
      >
        {gettext("Delete")}
      </button>
    <% else %>
      <button
        type="button"
        phx-click="open-page"
        phx-value-id={menu.id}
        class="block w-full px-4 py-2 text-left text-sm hover:bg-gray-100"
      >
        {gettext("Open")}
      </button>

      <.link
        patch={~p"/cms/pages/#{menu.id}"}
        class="block w-full px-4 py-2 text-left text-sm hover:bg-gray-100"
      >
        {gettext("Edit")}
      </.link>

      <button
        type="button"
        phx-value-id={menu.id}
        phx-click={
          JS.dispatch("ultra-confirm",
            detail: %{message: gettext("Are you sure you want to delete this page?")}
          )
        }
        phx-ultra-confirm-ok={JS.push("delete-page")}
        class="block w-full px-4 py-2 text-left text-sm text-red-600 hover:bg-gray-100"
      >
        {gettext("Delete")}
      </button>
    <% end %>
  </:menu_slots>
</.context_menu>
```
---

## Recommended pattern

Use this structure when supporting multiple resource types:

```heex
<.context_menu context_menu={@context_menu}>
  <:menu_slots :let={menu}>
    <%= cond do %>
      <% menu.type == "page" -> %>
        <!-- page actions -->

      <% menu.type == "directory" -> %>
        <!-- directory actions -->

      <% menu.type == "component" -> %>
        <!-- component actions -->
    <% end %>
  </:menu_slots>
</.context_menu>
```

This keeps all menu definitions in one place and makes new types easy to add.
