defmodule ScalesCmsWeb.SaveRequestUri do
  @moduledoc """
  Hooks into on_mount to keep track of current uri
  """
  def on_mount(:save_request_uri, _params, _session, socket),
    do:
      {:cont,
       Phoenix.LiveView.attach_hook(
         socket,
         :save_request_path,
         :handle_params,
         &save_request_path/3
       )}

  defp save_request_path(_params, url, socket),
    do: {:cont, Phoenix.Component.assign(socket, :current_uri, URI.parse(url) |> Map.get(:path))}
end
