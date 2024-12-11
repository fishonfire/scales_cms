defmodule ScalesCms do
  @moduledoc """
  ScalesCms keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @repo Application.compile_env(:scales_cms, :repo)

  def repo(), do: @repo
end
