import { Editor } from "@tiptap/core";
import {
  MarkdownSerializer,
  defaultMarkdownSerializer,
} from "@tiptap/pm/markdown";
import StarterKit from "@tiptap/starter-kit";
import Link from "@tiptap/extension-link";
import { marked } from "marked";

const LIST_ITEM_NAME = "listItem";

const isBlankParagraph = (node) => {
  const text = (node.textContent || "").replace(/\u00A0/g, "").trim();
  return text === "";
};

const serializeParagraph = (state, node) => {
  if (isBlankParagraph(node)) {
    state.write("&nbsp;");
    state.closeBlock(node);
    return;
  }

  defaultMarkdownSerializer.nodes.paragraph(state, node);
};

const markdownSerializer = new MarkdownSerializer(
  {
    blockquote: defaultMarkdownSerializer.nodes.blockquote,
    bulletList: defaultMarkdownSerializer.nodes.bullet_list,
    codeBlock: defaultMarkdownSerializer.nodes.code_block,
    heading: defaultMarkdownSerializer.nodes.heading,
    horizontalRule: defaultMarkdownSerializer.nodes.horizontal_rule,
    orderedList: defaultMarkdownSerializer.nodes.ordered_list,
    listItem: defaultMarkdownSerializer.nodes.list_item,
    paragraph: serializeParagraph,
    hardBreak: defaultMarkdownSerializer.nodes.hard_break,
    text: defaultMarkdownSerializer.nodes.text,
  },
  {
    bold: defaultMarkdownSerializer.marks.strong,
    italic: defaultMarkdownSerializer.marks.em,
    link: defaultMarkdownSerializer.marks.link,
    code: defaultMarkdownSerializer.marks.code,
    strike: {
      open: "~~",
      close: "~~",
      mixable: true,
      expelEnclosingWhitespace: true,
    },
  },
);

function markdownToHtml(markdown) {
  return marked.parse(
    markdown.replace(/^[\u200B\u200C\u200D\u200E\u200F\uFEFF]/, ""),
    {
      gfm: true,
      breaks: true,
    },
  );
}

export default {
  mounted() {
    this.targetNode = this.el.querySelector("[data-markdown-editor]");
    this.toolbar = this.el.querySelector("[data-markdown-toolbar]");
    this.inputTarget = document.getElementById(this.el.dataset.inputId);

    if (!this.targetNode || !this.inputTarget) return;

    this.toolbarMouseDownHandler = (event) => {
      if (event.target.closest("button")) event.preventDefault();
    };

    this.toolbarClickHandler = (event) => {
      const button = event.target.closest("button[data-command]");
      if (!button || this.isDisabled()) return;

      event.preventDefault();
      this.executeCommand(button);
    };

    this.editor = new Editor({
      element: this.targetNode,
      editable: !this.isDisabled(),
      extensions: [
        StarterKit.configure({
          heading: {
            levels: [1, 2, 3, 4, 5],
          },
        }),
        Link.configure({
          autolink: true,
          linkOnPaste: true,
          openOnClick: false,
          HTMLAttributes: {
            rel: "noopener noreferrer nofollow",
            target: "_blank",
          },
        }),
      ],
      content: markdownToHtml(this.inputTarget.value || ""),
      editorProps: {
        attributes: {
          class: "tiptap-content",
        },
      },
      onUpdate: ({ editor }) => {
        if (this.isDisabled()) return;

        const markdown = markdownSerializer.serialize(editor.state.doc);

        this.inputTarget.value = markdown;
        this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
        this.syncToolbarState();
      },
      onSelectionUpdate: () => this.syncToolbarState(),
      onFocus: () => this.syncToolbarState(),
      onBlur: () => this.syncToolbarState(),
      onCreate: () => this.syncToolbarState(),
    });

    this.toolbar?.addEventListener("mousedown", this.toolbarMouseDownHandler);
    this.toolbar?.addEventListener("click", this.toolbarClickHandler);

    this.syncDisabledState();
  },

  updated() {
    this.syncDisabledState();
    this.syncToolbarState();
  },

  destroyed() {
    this.toolbar?.removeEventListener(
      "mousedown",
      this.toolbarMouseDownHandler,
    );
    this.toolbar?.removeEventListener("click", this.toolbarClickHandler);
    this.editor?.destroy();
  },

  isDisabled() {
    return this.el.dataset.disabled === "true";
  },

  syncDisabledState() {
    const disabled = this.isDisabled();

    this.editor?.setEditable(!disabled);
    this.targetNode?.classList.toggle("is-disabled", disabled);
    this.syncToolbarState();
  },

  executeCommand(button) {
    const command = button.dataset.command;
    const level = Number(button.dataset.level);

    switch (command) {
      case "bold":
        this.editor.chain().focus().toggleBold().run();
        break;
      case "italic":
        this.editor.chain().focus().toggleItalic().run();
        break;
      case "strike":
        this.editor.chain().focus().toggleStrike().run();
        break;
      case "link":
        this.toggleLink();
        break;
      case "heading":
        this.editor.chain().focus().toggleHeading({ level }).run();
        break;
      case "blockquote":
        this.editor.chain().focus().toggleBlockquote().run();
        break;
      case "codeBlock":
        this.editor.chain().focus().toggleCodeBlock().run();
        break;
      case "bulletList":
        this.editor.chain().focus().toggleBulletList().run();
        break;
      case "orderedList":
        this.editor.chain().focus().toggleOrderedList().run();
        break;
      case "liftListItem":
        this.editor.chain().focus().liftListItem(LIST_ITEM_NAME).run();
        break;
      case "sinkListItem":
        this.editor.chain().focus().sinkListItem(LIST_ITEM_NAME).run();
        break;
      case "undo":
        this.editor.chain().focus().undo().run();
        break;
      case "redo":
        this.editor.chain().focus().redo().run();
        break;
    }

    this.syncToolbarState();
  },

  toggleLink() {
    const currentHref = this.editor.getAttributes("link").href || "";
    const href = window.prompt("Enter a URL", currentHref);

    if (href === null) return;

    if (href.trim() === "") {
      this.editor.chain().focus().extendMarkRange("link").unsetLink().run();
      return;
    }

    this.editor
      .chain()
      .focus()
      .extendMarkRange("link")
      .setLink({ href: href.trim() })
      .run();
  },

  syncToolbarState() {
    if (!this.toolbar || !this.editor) return;

    const disabled = this.isDisabled();
    const buttons = this.toolbar.querySelectorAll("button[data-command]");

    buttons.forEach((button) => {
      const command = button.dataset.command;
      const level = Number(button.dataset.level);

      button.disabled = disabled || !this.canRunCommand(command);
      button.classList.toggle(
        "is-active",
        this.isCommandActive(command, level),
      );
    });
  },

  canRunCommand(command) {
    if (!this.editor) return false;
    if (command === "link") return true;

    const chain = this.editor.can().chain().focus();

    switch (command) {
      case "bold":
        return chain.toggleBold().run();
      case "italic":
        return chain.toggleItalic().run();
      case "strike":
        return chain.toggleStrike().run();
      case "heading":
        return true;
      case "blockquote":
        return chain.toggleBlockquote().run();
      case "codeBlock":
        return chain.toggleCodeBlock().run();
      case "bulletList":
        return chain.toggleBulletList().run();
      case "orderedList":
        return chain.toggleOrderedList().run();
      case "liftListItem":
        return chain.liftListItem(LIST_ITEM_NAME).run();
      case "sinkListItem":
        return chain.sinkListItem(LIST_ITEM_NAME).run();
      case "undo":
        return chain.undo().run();
      case "redo":
        return chain.redo().run();
      default:
        return true;
    }
  },

  isCommandActive(command, level) {
    if (!this.editor) return false;

    switch (command) {
      case "bold":
        return this.editor.isActive("bold");
      case "italic":
        return this.editor.isActive("italic");
      case "strike":
        return this.editor.isActive("strike");
      case "link":
        return this.editor.isActive("link");
      case "heading":
        return this.editor.isActive("heading", { level });
      case "blockquote":
        return this.editor.isActive("blockquote");
      case "codeBlock":
        return this.editor.isActive("codeBlock");
      case "bulletList":
        return this.editor.isActive("bulletList");
      case "orderedList":
        return this.editor.isActive("orderedList");
      default:
        return false;
    }
  },
};
