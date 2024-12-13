if Application.compile_env(:scales_cms, :dev_mode) do
  defmodule ScalesCmsWeb.DevEnv.UserLoginLive do
    use ScalesCmsWeb, :live_view

    def render(assigns) do
      ~H"""
      <p>Welcome to this test page</p>
      <.simple_form for={%{}} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
      """
    end
  end
end
