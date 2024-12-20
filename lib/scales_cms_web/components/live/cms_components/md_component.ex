defmodule ScalesCmsWeb.Components.CmsComponents.Md do
  @moduledoc """
  The markdown component, allowing the user to use a HTML WYSIWYG editor,
  transforming that HTML back to MD
  """
  use ScalesCmsWeb, :live_component

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: gettext("Markdown"),
    category: "Content",
    description: gettext("Small or lang text like title or description"),
    icon_type: "cms_rich_text",
    preview_module: ScalesCmsWeb.Components.CmsComponents.Md.MdEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
