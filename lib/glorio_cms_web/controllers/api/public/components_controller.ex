defmodule GlorioCmsWeb.Api.Public.ComponentsController do
  use GlorioCmsWeb, :controller

  def index(conn, _params) do
    conn
    |> render(:index, components: GlorioCmsWeb.Components.CmsComponents.get_components())
  end
end
