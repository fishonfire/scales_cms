const ContextMenu = {
  mounted() {
    this.el.addEventListener("contextmenu", (e) => {
      e.preventDefault();

      this.pushEvent("open-context-menu", {
        x: e.clientX,
        y: e.clientY,
        id: this.el.dataset.id,
        type: this.el.dataset.type,
      });
    });
  },
};

export default ContextMenu;
