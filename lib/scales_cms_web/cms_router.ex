defmodule ScalesCmsWeb.CmsRouter do
  @moduledoc """
  The Macros for defining the routes in the main application
  """
  defmacro cms_admin(opts, do: block) do
    scope =
      quote bind_quoted: binding() do
        session_opts = [root_layout: {ScalesCmsWeb.Layouts, :root}]

        # Always include the SidebarState hook for session-based sidebar persistence
        sidebar_hook = {ScalesCmsWeb.Hooks.SidebarState, :default}
        request_uri_hook = {ScalesCmsWeb.SaveRequestUri, :save_request_uri}

        existing_hooks = opts[:on_mount] || []
        # Ensure existing_hooks is a list
        existing_hooks = if is_list(existing_hooks), do: existing_hooks, else: [existing_hooks]
        # Append sidebar hook to existing hooks
        all_hooks = existing_hooks ++ [sidebar_hook, request_uri_hook]

        session_opts = Keyword.put(session_opts, :on_mount, all_hooks)

        # Copy sidebar_open from Plug session to LiveView session
        # This allows the on_mount hook to read the persisted sidebar state
        session_opts =
          Keyword.put(
            session_opts,
            :session,
            {ScalesCmsWeb.Hooks.SidebarState, :copy_session, []}
          )

        live_session :cms_admin, session_opts do
          scope "/cms", ScalesCmsWeb do
            # cms assets

            get "/stats", CmsStatsController, :index

            # cms routes
            live "/", CmsIndexLive.Index, :index

            live "/settings", CmsSettingsLive.Index, :index

            live "/directories", CmsDirectoryLive.Index, :index
            live "/directories/new", CmsDirectoryLive.Index, :new
            live "/directories/:id", CmsDirectoryLive.Index, :index
            live "/directories/:id/new", CmsDirectoryLive.Index, :new

            live "/directories/:id/edit", CmsDirectoryLive.Index, :edit

            live "/directories/:id/show/edit", CmsDirectoryLive.Show, :edit

            live "/pages", CmsPageLive.Index, :index
            live "/pages/new", CmsPageLive.Index, :new
            live "/pages/:id/new", CmsPageLive.Index, :new
            live "/pages/:id/edit", CmsPageLive.Index, :edit

            live "/pages/:id", CmsPageLive.Show, :show
            live "/pages/:id/show/edit", CmsPageLive.Show, :edit

            live "/page_variants", CmsPageVariantLive.Index, :index
            live "/page_variants/new", CmsPageVariantLive.Index, :new
            live "/page_variants/:id/edit", CmsPageVariantLive.Index, :edit

            live "/page_variants/:id", CmsPageVariantLive.Show, :show
            live "/page_variants/:id/show/edit", CmsPageVariantLive.Show, :edit

            live "/page_builder/:id", PageBuilderLive.Edit, :edit
            live "/page_builder/:id/edit", PageBuilderLive.Edit, :edit_variant

            live "/media", CmsMediaLibraryLive.Index, :index

            block
          end
        end
      end

    if Code.ensure_loaded?(Phoenix.VerifiedRoutes) do
      quote do
        unquote(scope)
      end
    else
      scope
    end
  end

  defmacro cms_assets() do
    scope =
      quote bind_quoted: binding() do
        scope "/cms", ScalesCmsWeb do
          get "/css-:md5", Plugs.Assets, :css, as: :cms_asset
          get "/js-:md5", Plugs.Assets, :js, as: :cms_asset
        end
      end

    if Code.ensure_loaded?(Phoenix.VerifiedRoutes) do
      quote do
        unquote(scope)
      end
    else
      scope
    end
  end

  defmacro api_public() do
    scope =
      quote bind_quoted: binding() do
        # Other scopes may use custom stacks.
        scope "/public", ScalesCmsWeb.Api.Public do
          get("/pages", PagesController, :index)
          get("/pages/:id", PagesController, :show)
          get("/pages/slug/:slug", PagesController, :show)
          get("/components", ComponentsController, :index)
        end
      end

    if Code.ensure_loaded?(Phoenix.VerifiedRoutes) do
      quote do
        unquote(scope)
      end
    else
      scope
    end
  end
end
