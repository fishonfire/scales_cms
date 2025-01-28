defmodule ScalesCmsWeb.Helpers.Date do
  @moduledoc """
  A starting point for date helpers
  """
  def human_readable_date(date) do
    Timex.format!(date, "{0D}-{0M}-{YYYY} {h24}:{m}")
  end
end
