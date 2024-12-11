defmodule ScalesCmsWeb.CmsIndexLive.Index do
  use ScalesCmsWeb, :live_view

  def handle_params(_params, _url, socket), do: {:noreply, socket}
end
