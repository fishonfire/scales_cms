if Application.compile_env(:scales_cms, :dev_mode) do
  defmodule ScalesCmsWeb.UserSessionController do
    use ScalesCmsWeb, :controller

    alias ScalesCmsWeb.UserAuth

    def create(conn, _) do
      conn
      |> put_flash(:info, "Welcome back")
      |> UserAuth.log_in_user(UserAuth.get_demo_user(), %{})
    end

    def delete(conn, _params) do
      conn
      |> put_flash(:info, "Logged out successfully.")
      |> UserAuth.log_out_user()
    end
  end
end
