defmodule ScalesCmsWeb.CmsRouter do
  @moduledoc """
  The macros for defining the routes in the main application.
  """

  defmacro cms_admin(opts, do: block) do
    scope =
      quote bind_quoted: [opts: opts, block: Macro.escape(block)] do
        session_opts = [root_layout: {ScalesCmsWeb.Layouts, :root}]

        sidebar_hook = {ScalesCmsWeb.Hooks.SidebarState, :default}
        request_uri_hook = {ScalesCmsWeb.SaveRequestUri, :save_request_uri}

        existing_hooks = opts[:on_mount] || []
        existing_hooks = if is_list(existing_hooks), do: existing_hooks, else: [existing_hooks]

        all_hooks = existing_hooks ++ [sidebar_hook, request_uri_hook]

        session_opts =
          session_opts
          |> Keyword.put(:on_mount, all_hooks)
          |> Keyword.put(:session, {ScalesCmsWeb.Hooks.SidebarState, :copy_session, []})

        live_session :cms_admin, session_opts do
          scope "/cms", ScalesCmsWeb do
            get "/stats", CmsStatsController, :index

            live "/", CmsIndexLive.Index, :index
            live "/settings", CmsSettingsLive.Index, :index

            live "/directories", CmsDirectoryLive.Index, :index
            live "/directories/:id", CmsDirectoryLive.Index, :index

            live "/pages", CmsPageLive.Index, :index
            live "/pages/:id", CmsPageLive.Show, :show
            live "/pages/:id/show/edit", CmsPageLive.Show, :edit

            live "/page_variants", CmsPageVariantLive.Index, :index
            live "/page_variants/:id", CmsPageVariantLive.Show, :show
            live "/page_variants/:id/show/edit", CmsPageVariantLive.Show, :edit

            live "/page_builder/:id", PageBuilderLive.Edit, :edit
            live "/page_builder/:id/edit", PageBuilderLive.Edit, :edit_variant

            live "/media", CmsMediaLibraryLive.Index, :index
          end

          scope "/" do
            unquote(block)
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
        scope "/public", ScalesCmsWeb.Api.Public do
          get "/pages", PagesController, :index
          get "/pages/:id", PagesController, :show
          get "/pages/slug/:slug", PagesController, :show
          get "/components", ComponentsController, :index
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
