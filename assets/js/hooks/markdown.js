import TurndownService from "turndown";
import { marked } from "marked";
import Trix from "trix";

var turndownService = new TurndownService();

turndownService.addRule("paragraph", {
  filter: "p",
  replacement: function (content) {
    return "\n\n" + content + "\n\n";
  },
});

Trix.config.blockAttributes.heading2 = {
  tagName: "h2",
  terminal: true,
  breakOnReturn: true,
};
Trix.config.blockAttributes.heading3 = {
  tagName: "h3",
  terminal: true,
  breakOnReturn: true,
};
Trix.config.blockAttributes.heading4 = {
  tagName: "h4",
  terminal: true,
  breakOnReturn: true,
};
Trix.config.blockAttributes.heading5 = {
  tagName: "h5",
  terminal: true,
  breakOnReturn: true,
};

export default {
  mounted() {
    this.targetNode = this.el.getElementsByTagName("trix-editor")?.[0];
    this.editor = this.targetNode?.editor;

    this.inputTarget = document.getElementById(
      this.targetNode.id.replace("editor", "content"),
    );

    let input = this.inputTarget.value;
    input = input.replaceAll(/\n/g, "<br>");

    const convertedHTML = marked.parse(
      input.replace(/^[\u200B\u200C\u200D\u200E\u200F\uFEFF]/, ""),
      {
        gfm: true,
        breaks: true,
      },
    );

    this.editor.insertHTML(convertedHTML);

    this.syncDisabledState();

    this.el.addEventListener("trix-change", () => {
      if (this.isDisabled()) return;

      let innerHTML = this.targetNode.innerHTML;
      innerHTML = innerHTML.replace("<br>", "\n");

      const markdown = turndownService.turndown(innerHTML);
      this.inputTarget.value = markdown;

      this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
    });
  },

  updated() {
    this.syncDisabledState();
  },

  isDisabled() {
    return this.el.dataset.disabled === "true";
  },

  syncDisabledState() {
    const disabled = this.isDisabled();

    if (!this.targetNode) return;

    this.targetNode.toggleAttribute("disabled", disabled);
    this.targetNode.setAttribute(
      "contenteditable",
      disabled ? "false" : "true",
    );

    const toolbarId = this.targetNode.getAttribute("toolbar");
    if (toolbarId) {
      const toolbar = document.getElementById(toolbarId);
      if (toolbar) {
        toolbar.style.pointerEvents = disabled ? "none" : "";
        toolbar.style.opacity = disabled ? "0.5" : "";
      }
    }
  },
};
