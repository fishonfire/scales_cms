defmodule ScalesCmsWeb.Api.Public.ComponentsController do
  use ScalesCmsWeb, :controller

  def index(conn, _params) do
    conn
    |> render(:index, components: ScalesCmsWeb.Components.CmsComponents.get_components())
  end
end
