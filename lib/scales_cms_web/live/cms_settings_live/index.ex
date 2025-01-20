defmodule ScalesCmsWeb.CmsSettingsLive.Index do
  use ScalesCmsWeb, :live_view

  alias ScalesCmsWeb.CmsSettingsLive.ApiKeyFormComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={ApiKeyFormComponent} id="api_key_form" />
    """
  end

  def handle_params(_params, _url, socket), do: {:noreply, socket}
end
