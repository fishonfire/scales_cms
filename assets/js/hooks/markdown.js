import showdown from 'showdown'
import TurndownService from 'turndown'

const converter = new showdown.Converter()
var turndownService = new TurndownService()

import Trix from "trix"

// document.addEventListener("trix-before-initialize", () => { /* Change Trix.config if you need */
Trix.config.blockAttributes.heading2 = {
  tagName: "h2",
  terminal: true,
  breakOnReturn: true
};
Trix.config.blockAttributes.heading3 = {
  tagName: "h3",
  terminal: true,
  breakOnReturn: true
};
Trix.config.blockAttributes.heading4 = {
  tagName: "h4",
  terminal: true,
  breakOnReturn: true
};
Trix.config.blockAttributes.heading5 = {
  tagName: "h5",
  terminal: true,
  breakOnReturn: true
};

export default {
  mounted() {
    const targetNode = this.el.getElementsByTagName('trix-editor')?.[0]
    const editor = targetNode.editor


    const inputTarget = document.getElementById(targetNode.id.replace('editor', 'content'))
    editor.insertHTML(converter.makeHtml(inputTarget.value))


    this.el.addEventListener('trix-change', (event) => {
      const markdown = turndownService.turndown(targetNode.innerHTML)
      inputTarget.value = markdown
      inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    })
  },
}
