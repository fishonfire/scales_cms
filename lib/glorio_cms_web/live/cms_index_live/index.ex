defmodule GlorioCmsWeb.CmsIndexLive.Index do
  use GlorioCmsWeb, :live_view

  def handle_params(_params, _url, socket), do: {:noreply, socket}
end
