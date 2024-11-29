import Quill from 'quill';
import TurndownService from 'turndown'

var turndownService = new TurndownService()


export default {
  mounted() {
    console.log('loading MD editor')

    const targetNode = this.el.getElementsByClassName('wysiwyg')[0]

    this.quill = new Quill(targetNode, {
      theme: "snow",
    });

    console.log('quill', this.quill)

    this.quill.on('text-change', (delta, oldDelta, source) => {
      var html = this.quill.container.firstChild.innerHTML;

      const markdown = turndownService.turndown(html)

      const inputTarget = document.getElementById(targetNode.id.replace('editor', 'content'))

      console.log(inputTarget)

      inputTarget.value = markdown

      this.pushEventTo(inputTarget, 'content_changed', { value: markdown })
    })

  },

  destroyed() {
    this.quill

    // this.crepe.destroy()
    // this.observer.disconnect()
  }
}
