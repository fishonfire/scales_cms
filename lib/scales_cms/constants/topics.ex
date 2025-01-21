defmodule ScalesCms.Constants.Topics do
  @moduledoc """
    Module containind topics for pubsub
  """
  @topic_block_updated "block_updated"

  def get_block_updated_topic, do: @topic_block_updated
end
