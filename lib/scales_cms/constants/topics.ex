defmodule ScalesCms.Constants.Topics do
  @moduledoc """
    Module containind topics for pubsub
  """
  @topic_set_locale "set_locale"

  def get_set_locale_topic(), do: @topic_set_locale

  @topic_block_updated "block_updated"

  def get_block_updated_topic, do: @topic_block_updated
end
