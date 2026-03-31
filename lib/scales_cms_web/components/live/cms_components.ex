defmodule ScalesCmsWeb.Components.CmsComponents do
  @moduledoc """
  An index of all components and insertable template blocks for the CMS drawer.
  """

  alias ScalesCms.Cms.CmsBlockTemplates

  alias ScalesCmsWeb.Components.CmsComponents.{
    Header,
    Dev,
    Md,
    Image,
    Lottie,
    Video,
    Button,
    CTAButton,
    ImageButton,
    ButtonCollection,
    ImageButtonCollection
  }

  @template_category "Templates"

  @component_list %{
    "header" => Header,
    "dev" => Dev,
    "md" => Md,
    "image" => Image,
    "video" => Video,
    "lottie" => Lottie,
    "button" => Button,
    "image_button" => ImageButton,
    "cta_button" => CTAButton,
    "button_collection" => ButtonCollection,
    "image_button_collection" => ImageButtonCollection
  }

  def get_components(), do: Map.merge(@component_list, get_custom_components())

  def get_custom_components(), do: Application.get_env(:scales_cms, :custom_components, %{})

  def get_component(key), do: Map.get(get_components(), key)

  def get_categories(locale \\ nil) do
    component_categories =
      get_components()
      |> Enum.map(fn {_key, component} -> component.category() end)

    template_categories =
      case get_template_blocks(locale) do
        templates when map_size(templates) > 0 -> [@template_category]
        _ -> []
      end

    (component_categories ++ template_categories)
    |> MapSet.new()
    |> Enum.to_list()
  end

  def get_components_for_category("All"), do: get_components()

  def get_components_for_category(category) do
    get_components()
    |> Enum.filter(fn {_key, component} ->
      component.category() == category
    end)
  end

  def get_template_blocks(locale \\ nil) do
    locale
    |> list_templates()
    |> Enum.into(%{}, fn template ->
      {
        template_key(template),
        %{
          type: :template,
          title: template.name,
          category: @template_category,
          component_type: template.component_type,
          template_family_id: template.template_family_id,
          locale: template.locale,
          icon_type: get_component_icon_type(template.component_type)
        }
      }
    end)
  end

  def get_insertables(locale \\ nil) do
    Map.merge(
      normalize_components_for_insertables(get_components()),
      get_template_blocks(locale)
    )
  end

  def get_insertables_for_category(category, locale \\ nil)
  def get_insertables_for_category("All", locale), do: get_insertables(locale)

  def get_insertables_for_category(@template_category, locale) do
    get_template_blocks(locale)
  end

  def get_insertables_for_category(category, _locale) do
    get_components_for_category(category)
    |> normalize_components_for_insertables()
  end

  defp normalize_components_for_insertables(components) do
    Enum.into(components, %{}, fn {key, component} ->
      {key,
       %{
         type: :component,
         key: key,
         title: component.title(),
         category: component.category(),
         description: component.description(),
         icon_type: component.icon_type(),
         component: component
       }}
    end)
  end

  defp list_templates(nil), do: CmsBlockTemplates.list_cms_block_templates()
  defp list_templates(locale), do: CmsBlockTemplates.list_cms_block_templates(locale)

  defp template_key(template), do: "template:#{template.template_family_id}"

  defp get_component_icon_type(component_type) do
    case get_component(component_type) do
      nil -> "cms_block"
      component -> component.icon_type()
    end
  end
end
