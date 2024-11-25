defmodule GlorioCmsWeb.Router do
  use GlorioCmsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GlorioCmsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GlorioCmsWeb do
    pipe_through :browser

    get "/", PageController, :home

    scope "/cms" do
      live "/cms_directories", CmsDirectoryLive.Index, :index
      live "/cms_directories/new", CmsDirectoryLive.Index, :new
      live "/cms_directories/:id", CmsDirectoryLive.Index, :index
      live "/cms_directories/:id/new", CmsDirectoryLive.Index, :new

      live "/cms_directories/:id/edit", CmsDirectoryLive.Index, :edit

      live "/cms_directories/:id/show/edit", CmsDirectoryLive.Show, :edit

      live "/cms_pages", CmsPageLive.Index, :index
      live "/cms_pages/new", CmsPageLive.Index, :new
      live "/cms_pages/:id/new", CmsPageLive.Index, :new
      live "/cms_pages/:id/edit", CmsPageLive.Index, :edit

      live "/cms_pages/:id", CmsPageLive.Show, :show
      live "/cms_pages/:id/show/edit", CmsPageLive.Show, :edit

      live "/cms_page_variants", CmsPageVariantLive.Index, :index
      live "/cms_page_variants/new", CmsPageVariantLive.Index, :new
      live "/cms_page_variants/:id/edit", CmsPageVariantLive.Index, :edit

      live "/cms_page_variants/:id", CmsPageVariantLive.Show, :show
      live "/cms_page_variants/:id/show/edit", CmsPageVariantLive.Show, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", GlorioCmsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:glorio_cms, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GlorioCmsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
