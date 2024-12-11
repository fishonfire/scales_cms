defmodule ScalesCms.Cms.Helpers.Locales do
  @moduledoc """
  The Locales helper offers a list of supported locales and the default locale
  """
  def all() do
    [
      %{code: "nl-NL", name: "Dutch"},
      %{code: "en-US", name: "English"},
      %{code: "fr-FR", name: "Français"}
    ]
  end

  def default_locale() do
    Application.get_env(:scales_cms, :cms)[:default_locale] || "en-US"
  end
end
