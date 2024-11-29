import Quill from 'quill';
import showdown from 'showdown'
import TurndownService from 'turndown'

const converter = new showdown.Converter()
var turndownService = new TurndownService()

import Trix from "trix"

export default {
  mounted() {
    console.log('loading MD editor')

    const targetNode = this.el.getElementsByTagName('trix-editor')?.[0]
    const editor = targetNode.editor
    console.log(targetNode)
    console.log(targetNode.editor)


    const inputTarget = document.getElementById(targetNode.id.replace('editor', 'content'))
    editor.insertHTML(converter.makeHtml(inputTarget.value))


    this.el.addEventListener('trix-change', (event) => {
      console.log(event)

      const markdown = turndownService.turndown(targetNode.innerHTML)
      inputTarget.value = markdown
      inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    })
    //

    // this.quill = new Quill(targetNode, {
    //   theme: "snow",
    // });

    // this.quill.setContents(this.quill.clipboard.convert({
    //   html: converter.makeHtml(inputTarget.value)
    // }))

    // this.quill.on('text-change', (delta, oldDelta, source) => {
    //   var html = this.quill.container.firstChild.innerHTML;

    //   const markdown = turndownService.turndown(html)

    //   inputTarget.value = markdown
    //   inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    // })

  },

  destroyed() {
    // this.quill

    // this.crepe.destroy()
    // this.observer.disconnect()
  }
}
