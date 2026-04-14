defmodule ScalesCmsWeb.Components.CmsComponents.Md.MdToolbar do
  @moduledoc false
  use ScalesCmsWeb, :html
  attr :id, :string, required: true

  def render(assigns) do
    ~H"""
    <div id={@id} class="tiptap-toolbar" data-markdown-toolbar>
      <div class="tiptap-toolbar-group">
        <button type="button" class="tiptap-toolbar-button" data-command="bold" title="Bold">
          Bold
        </button>
        <button type="button" class="tiptap-toolbar-button" data-command="italic" title="Italic">
          Italic
        </button>
        <button
          type="button"
          class="tiptap-toolbar-button"
          data-command="strike"
          title="Strikethrough"
        >
          Strike
        </button>
        <button type="button" class="tiptap-toolbar-button" data-command="link" title="Link">
          Link
        </button>
      </div>

      <div class="tiptap-toolbar-group">
        <button type="button" class="tiptap-toolbar-button" data-command="heading" data-level="1">
          H1
        </button>
        <button type="button" class="tiptap-toolbar-button" data-command="heading" data-level="2">
          H2
        </button>
        <button type="button" class="tiptap-toolbar-button" data-command="heading" data-level="3">
          H3
        </button>
        <button type="button" class="tiptap-toolbar-button" data-command="heading" data-level="4">
          H4
        </button>
        <button type="button" class="tiptap-toolbar-button" data-command="heading" data-level="5">
          H5
        </button>
      </div>

      <div class="tiptap-toolbar-group">
        <button
          type="button"
          class="tiptap-toolbar-button"
          data-command="blockquote"
          title="Block quote"
        >
          Quote
        </button>
        <button type="button" class="tiptap-toolbar-button" data-command="codeBlock" title="Code block">
          Code
        </button>
        <button
          type="button"
          class="tiptap-toolbar-button"
          data-command="bulletList"
          title="Bullet list"
        >
          Bullets
        </button>
        <button
          type="button"
          class="tiptap-toolbar-button"
          data-command="orderedList"
          title="Numbered list"
        >
          Numbers
        </button>
        <button
          type="button"
          class="tiptap-toolbar-button"
          data-command="liftListItem"
          title="Decrease list nesting"
        >
          Outdent
        </button>
        <button
          type="button"
          class="tiptap-toolbar-button"
          data-command="sinkListItem"
          title="Increase list nesting"
        >
          Indent
        </button>
      </div>

      <div class="tiptap-toolbar-group">
        <button type="button" class="tiptap-toolbar-button" data-command="undo" title="Undo">
          Undo
        </button>
        <button type="button" class="tiptap-toolbar-button" data-command="redo" title="Redo">
          Redo
        </button>
      </div>
    </div>
    """
  end
end
