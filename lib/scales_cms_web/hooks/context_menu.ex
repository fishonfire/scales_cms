defmodule ScalesCmsWeb.Hooks.ContextMenu do
  @moduledoc """
  Shared LiveView hook for context menu state and events.
  """

  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> assign_new(:context_menu, fn -> nil end)
      |> attach_hook(:context_menu_events, :handle_event, &handle_event/3)

    {:cont, socket}
  end

  defp handle_event(
         "open-context-menu",
         %{"x" => x, "y" => y, "type" => type, "id" => id},
         socket
       ) do
    {:halt,
     assign(socket, :context_menu, %{
       x: x,
       y: y,
       type: type,
       id: id
     })}
  end

  defp handle_event("close-context-menu", _params, socket) do
    {:halt, assign(socket, :context_menu, nil)}
  end

  defp handle_event(_event, _params, socket) do
    {:cont, socket}
  end
end
