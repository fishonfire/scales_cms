defmodule ScalesCmsWeb.Components.CmsComponents.Md.MdToolbar do
  use ScalesCmsWeb, :html

  def render(assigns) do
    ~H"""
    <div class="trix-button-row">
      <span
        class="trix-button-group trix-button-group--text-tools"
        data-trix-button-group="text-tools"
      >
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-bold"
          data-trix-attribute="bold"
          data-trix-key="b"
          title="Bold"
          tabindex="-1"
        >
          Bold
        </button>
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-italic"
          data-trix-attribute="italic"
          data-trix-key="i"
          title="Italic"
          tabindex="-1"
        >
          Italic
        </button>
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-strike"
          data-trix-attribute="strike"
          title="Strikethrough"
          tabindex="-1"
        >
          Strikethrough
        </button>
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-link"
          data-trix-attribute="href"
          data-trix-action="link"
          data-trix-key="k"
          title="Link"
          tabindex="-1"
        >
          Link
        </button>
      </span>
      <span
        class="trix-button-group trix-button-group--block-tools"
        data-trix-button-group="block-tools"
      >
        <button
          type="button"
          class="trix-button"
          data-trix-attribute="heading1"
          title="Heading"
          tabindex="-1"
        >
          H1
        </button>
        <button
          type="button"
          class="trix-button"
          data-trix-attribute="heading2"
          title="Heading"
          tabindex="-1"
        >
          H2
        </button>
        <button
          type="button"
          class="trix-button"
          data-trix-attribute="heading3"
          title="Heading"
          tabindex="-1"
        >
          H3
        </button>
        <button
          type="button"
          class="trix-button"
          data-trix-attribute="heading4"
          title="Heading"
          tabindex="-1"
        >
          H4
        </button>
        <button
          type="button"
          class="trix-button"
          data-trix-attribute="heading5"
          title="Heading"
          tabindex="-1"
        >
          H5
        </button>

        <span class="trix-button-group-spacer"></span>

        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-quote"
          data-trix-attribute="quote"
          title="Quote"
          tabindex="-1"
        >
          Quote
        </button>
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-code"
          data-trix-attribute="code"
          title="Code"
          tabindex="-1"
        >
          Code
        </button>
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-bullet-list"
          data-trix-attribute="bullet"
          title="Bullets"
          tabindex="-1"
        >
          Bullets
        </button>
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-number-list"
          data-trix-attribute="number"
          title="Numbers"
          tabindex="-1"
        >
          Numbers
        </button>
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-decrease-nesting-level"
          data-trix-action="decreaseNestingLevel"
          title="Decrease Level"
          tabindex="-1"
        >
          Decrease Level
        </button>
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-increase-nesting-level"
          data-trix-action="increaseNestingLevel"
          title="Increase Level"
          tabindex="-1"
        >
          Increase Level
        </button>
      </span>

      <span class="trix-button-group-spacer"></span>

      <span
        class="trix-button-group trix-button-group--history-tools"
        data-trix-button-group="history-tools"
      >
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-undo"
          data-trix-action="undo"
          data-trix-key="z"
          title="Undo"
          tabindex="-1"
        >
          Undo
        </button>
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-redo"
          data-trix-action="redo"
          data-trix-key="shift+z"
          title="Redo"
          tabindex="-1"
        >
          Redo
        </button>
      </span>
    </div>
    <div class="trix-dialogs" data-trix-dialogs>
      <div
        class="trix-dialog trix-dialog--link"
        data-trix-dialog="href"
        data-trix-dialog-attribute="href"
      >
        <div class="trix-dialog__link-fields">
          <input
            type="url"
            name="href"
            class="trix-input trix-input--dialog"
            placeholder="Enter a URL…"
            aria-label="URL"
            required
            data-trix-input
          />
          <div class="trix-button-group">
            <input
              type="button"
              class="trix-button trix-button--dialog"
              value="Link"
              data-trix-method="setAttribute"
            />
            <input
              type="button"
              class="trix-button trix-button--dialog"
              value="Unlink"
              data-trix-method="removeAttribute"
            />
          </div>
        </div>
      </div>
    </div>
    """
  end
end
