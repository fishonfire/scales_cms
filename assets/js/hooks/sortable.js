import Sortable from 'sortablejs'

export default {
  mounted() {
    const sortable = new Sortable(this.el, {
      animation: 1,
      delay: 4,
      delayOnTouchOnly: true,
      group: 'shared',
      draggable: '.draggable',
      ghostClass: 'sortable-ghost',
      handle: ".drag-handle",
      onEnd: (evt) => {
        // console.log(sortable.toArray())
        evt.preventDefault()
        console.log('onEnd');

        this.pushEvent('dropped', {
          draggedId: evt.item.id, // id of the dragged item
          toDropzoneId: evt.to.id, // id of the drop zone where the drop occured
          fromDropzoneId: evt.from.id, // id of the drop zone where the drop occured
          newDraggableIndex: evt.newDraggableIndex, // index where the item was dropped (relative to other items in the drop zone)
          oldDraggableIndex: evt.oldDraggableIndex, // index where the item was dropped (relative to other items in the drop zone)
          newOrder: sortable.toArray()
        })
      },
    });
  }
};
