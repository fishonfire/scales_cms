defmodule GlorioCms.Cms.Helpers.Slugify do
  @moduledoc """
  A slugify helper thanks to Mudassar (https://mudssrali.com/blog/slugify-a-string-in-elixir)
  """
  def slugify(text) when is_binary(text) do
    text
    |> String.downcase()
    |> String.trim()
    |> String.normalize(:nfd)
    |> String.replace(~r/[^a-z0-9\s-]/u, "  ")
    |> String.replace(~r/[\s-]+/, "-", global: true)
  end

  def slugify(_), do: ""
end
