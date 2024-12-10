defmodule GlorioCmsWeb.Components.CmsComponents.Md do
  @moduledoc """
  The markdown component, allowing the user to use a HTML WYSIWYG editor,
  transforming that HTML back to MD
  """
  use GlorioCmsWeb, :live_component

  use GlorioCmsWeb.Components.HelperComponents.RootComponent,
    title: gettext("Markdown"),
    category: "Content",
    description: gettext("Small or lang text like title or description"),
    icon_type: "cms_rich_text",
    preview_module: GlorioCmsWeb.Components.CmsComponents.Md.MdEditor
end
