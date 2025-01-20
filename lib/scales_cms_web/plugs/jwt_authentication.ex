defmodule ScalesCmsWeb.Plugs.JwtAuthentication do
  @moduledoc """
    This plug authenticates the API request based on JWT
  """

  use Guardian.Plug.Pipeline,
    otp_app: :scales_cms,
    error_handler: ScalesCms.ErrorHandler,
    module: ScalesCms.Guardian

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
