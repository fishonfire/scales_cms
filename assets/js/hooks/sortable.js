import Sortable from "sortablejs";

export default {
  mounted() {
    const isDrawer = this.el.id === "drawer";
    const isPageDropZone = this.el.id === "page-drop-zone";

    this.sortable = new Sortable(this.el, {
      animation: isPageDropZone ? 180 : 120,
      easing: "cubic-bezier(0.2, 0, 0, 1)",
      delay: 4,
      delayOnTouchOnly: true,

      group: isDrawer
        ? {
            name: "cms",
            pull: "clone",
            put: false,
          }
        : {
            name: "cms",
            pull: true,
            put: ["cms"],
          },

      sort: isDrawer ? false : true,

      draggable: ".draggable",
      ghostClass: "sortable-ghost",
      chosenClass: "sortable-chosen",
      dragClass: "sortable-drag",
      handle: ".drag-handle",

      onStart: (evt) => {
        document.body.classList.add("is-sorting");

        if (isDrawer) {
          evt.item.classList.add("from-drawer");
        }
      },

      onMove: (evt) => {
        if (!isPageDropZone) return true;

        const pageDropZone = document.getElementById("page-drop-zone");

        if (evt.to?.id === "page-drop-zone") {
          pageDropZone?.classList.add("is-drop-target-active");
        } else {
          pageDropZone?.classList.remove("is-drop-target-active");
        }

        return true;
      },

      onAdd: (evt) => {
        if (isPageDropZone) {
          evt.item.classList.add("block-drop-enter");

          setTimeout(() => {
            evt.item.classList.remove("block-drop-enter");
          }, 240);
        }
      },

      onEnd: (evt) => {
        evt.preventDefault();

        document.body.classList.remove("is-sorting");
        evt.item.classList.remove("from-drawer");

        if (isPageDropZone) {
          this.el.classList.remove("is-drop-target-active");
        }

        const newOrder = Array.from(evt.to.children)
          .map((el) => el.dataset.id || el.id)
          .filter(Boolean);

        this.pushEvent("dropped", {
          draggedId: evt.item.id,
          toDropzoneId: evt.to.id,
          fromDropzoneId: evt.from.id,
          newDraggableIndex: evt.newDraggableIndex,
          oldDraggableIndex: evt.oldDraggableIndex,
          newOrder,
        });
      },
    });
  },

  destroyed() {
    this.sortable?.destroy();
  },
};
