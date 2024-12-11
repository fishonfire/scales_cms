defmodule ScalesCms.Constants.Topics do
  @moduledoc """
    Module containind topics for pubsub
  """
  @topic_set_locale "set_locale"

  def get_set_locale_topic(), do: @topic_set_locale
end
