defmodule ScalesCmsWeb.CmsSettingsLive.ApiKeyFormComponent do
  @moduledoc """
  CMS Settings LiveView component for managing API keys.
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Cms.CmsApiToken
  alias ScalesCms.Cms.CmsApiTokens

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    cms_api_token = CmsApiTokens.get_most_recent_api_token() || %CmsApiToken{}
    changeset = CmsApiToken.changeset(cms_api_token, %{})

    socket
    |> assign(assigns)
    |> assign(form: to_form(changeset))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("generate_token", _params, socket) do
    {:ok, cms_api_token} = CmsApiTokens.create_cms_api_token()
    changeset = CmsApiToken.changeset(cms_api_token, %{})

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-submit="store-properties" phx-target={@myself}>
        <.input type="textarea" field={@form[:token]} label="API Access Token" />
        <:actions>
          <.button type="button" phx-click="generate_token" phx-target={@myself} class="btn-primary">
            {gettext("Generate Token")}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
