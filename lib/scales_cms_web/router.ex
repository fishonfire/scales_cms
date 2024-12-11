defmodule ScalesCmsWeb.Router do
  use ScalesCmsWeb, :router

  import ScalesCmsWeb.CmsRouter
  import ScalesCmsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ScalesCmsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug(ScalesCmsWeb.Plugs.ApiVersion)
  end

  scope "/", ScalesCmsWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/users/log_in", DevEnv.UserLoginLive
    post "/users/log_in", UserSessionController, :create
  end

  scope "/" do
    pipe_through [:browser, :require_authenticated_user]
    cms_admin(on_mount: [{ScalesCmsWeb.UserAuth, :ensure_authenticated}])
  end

  scope "/api" do
    pipe_through :api

    api_public()
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:scales_cms, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ScalesCmsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
