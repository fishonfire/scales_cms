defmodule ScalesCmsWeb.CmsBlockTemplatesLive.Edit do
  alias ScalesCmsWeb.Components.CmsComponents
  alias ScalesCms.Cms.CmsBlockTemplates
  use ScalesCmsWeb, :live_view

  alias ScalesCmsWeb.Components.LocaleSwitcher
  import ScalesCmsWeb.Components.CmsComponentsRenderer

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(title: "") |> assign(drawer_open: true)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _, socket) do
    cms_block_template = CmsBlockTemplates.get_cms_block_template!(id)

    socket
    |> assign_form(cms_block_template)
    |> assign(:cms_block_template, cms_block_template)
    |> assign(:locale, cms_block_template.locale)
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveView
  def handle_info({LocaleSwitcher, {:locale_switched, locale}}, socket) do
    template = CmsBlockTemplates.get_cms_block_template!(socket.assigns.cms_block_template.id)
    template_locale = template.locale

    case locale do
      ^template_locale ->
        {:noreply, socket}

      _ ->
        localized_template =
          CmsBlockTemplates.get_or_create_localized_variant!(template, locale)

        {:noreply, push_navigate(socket, to: ~p"/cms/block_templates/#{localized_template.id}")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("toggle-drawer", _, socket) do
    {:noreply, update(socket, :drawer_open, &(!&1))}
  end

  def handle_event("publish", _, socket) do
    {:ok, cms_block_template} =
      CmsBlockTemplates.publish_cms_block_template(socket.assigns.cms_block_template)

    socket
    |> assign(cms_block_template: cms_block_template)
    |> assign_form(cms_block_template)
    |> then(&{:noreply, &1})
  end

  def handle_event("update", %{"cms_block_template" => attrs}, socket) do
    case CmsBlockTemplates.update_cms_block_template(socket.assigns.cms_block_template, attrs) do
      {:error, _changeset} ->
        socket
        |> then(&{:noreply, &1})

      {:ok, cms_block_template} ->
        socket
        |> assign(cms_block_template: cms_block_template)
        |> assign_form(cms_block_template)
        |> then(&{:noreply, &1})
    end
  end

  defp component_type_options() do
    CmsComponents.get_components() |> Enum.map(fn {key, _val} -> {key, key} end)
  end

  defp template_mode_options() do
    %{
      :live => "live",
      :snapshot => "snapshot"
    }
  end

  defp template_mode_description(:live) do
    gettext(
      "Updates automatically across all pages using this template. Changes take effect immediately."
    )
  end

  defp template_mode_description(:snapshot) do
    gettext(
      "Uses the template as a starting point. When a page is published, the content is frozen and no longer updates automatically."
    )
  end

  defp template_mode_description(_), do: nil

  defp assign_form(socket, cms_block_template) do
    form =
      to_form(CmsBlockTemplates.change_cms_block_template(cms_block_template))

    socket |> assign(form: form)
  end
end
