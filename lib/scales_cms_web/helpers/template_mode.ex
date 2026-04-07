defmodule ScalesCmsWeb.Helpers.TemplateMode do
  @moduledoc """
  Shared presentation helpers for template mode badges and indicators.
  """

  def label(:live), do: "Live mode"
  def label(:snapshot), do: "Snapshot mode"
  def label(:detached), do: "Detached mode"
  def label(_), do: "Unknown mode"

  def dot_class(:live), do: "bg-green-500"
  def dot_class(:snapshot), do: "bg-blue"
  def dot_class(:detached), do: "bg-gray-600"
  def dot_class(_), do: "bg-slate-300"

  def badge_text_class(:live), do: "text-green-800"
  def badge_text_class(:snapshot), do: "text-blue"
  def badge_text_class(:detached), do: "text-slate-700"
  def badge_text_class(_), do: "text-slate-700"
end
