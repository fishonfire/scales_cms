const ContextMenuButton = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const rect = this.el.getBoundingClientRect();

      this.pushEvent("open-context-menu", {
        type: this.el.dataset.type,
        id: this.el.dataset.id,
        x: rect.left,
        y: rect.bottom,
      });
    });
  },
};

export default ContextMenuButton;
