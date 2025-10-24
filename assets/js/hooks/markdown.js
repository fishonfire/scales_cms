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

// document.addEventListener("trix-before-initialize", () => { /* Change Trix.config if you need */
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
    const targetNode = this.el.getElementsByTagName("trix-editor")?.[0];
    const editor = targetNode.editor;

    const inputTarget = document.getElementById(
      targetNode.id.replace("editor", "content"),
    );

    let input = inputTarget.value;

    input = input.replaceAll(/\n/g, "<br>");

    const convertedHTML = marked.parse(
      input.replace(/^[\u200B\u200C\u200D\u200E\u200F\uFEFF]/, ""),
      {
        gfm: true,
        breaks: true,
      },
    );

    editor.insertHTML(convertedHTML);

    this.el.addEventListener("trix-change", (event) => {
      let innerHTML = targetNode.innerHTML;

      innerHTML = innerHTML.replace("<br>", "\n");

      const markdown = turndownService.turndown(innerHTML);
      inputTarget.value = markdown;

      inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
    });
  },
};
