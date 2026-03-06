const DragDropZone = {
  mounted() {
    this.dragCounter = 0;

    // Make the entire drop zone clickable to trigger file input
    this.el.addEventListener("click", (e) => {
      // Don't trigger if clicking on the label or input itself
      if (e.target.tagName === "LABEL" || e.target.tagName === "INPUT") {
        return;
      }
      const fileInput = this.el.querySelector("input[type='file']");
      if (fileInput) {
        fileInput.click();
      }
    });

    this.el.addEventListener("dragenter", (e) => {
      e.preventDefault();
      this.dragCounter++;
      if (this.dragCounter === 1) {
        this.activateDragState();
      }
    });

    this.el.addEventListener("dragleave", (e) => {
      e.preventDefault();
      this.dragCounter--;
      if (this.dragCounter === 0) {
        this.deactivateDragState();
      }
    });

    this.el.addEventListener("dragover", (e) => {
      e.preventDefault();
    });

    this.el.addEventListener("drop", (e) => {
      this.dragCounter = 0;
      this.deactivateDragState();
    });
  },

  activateDragState() {
    const activeClasses = this.el.dataset.activeClass;
    if (activeClasses) {
      activeClasses.split(" ").forEach((cls) => {
        if (cls) this.el.classList.add(cls);
      });
    }
  },

  deactivateDragState() {
    const activeClasses = this.el.dataset.activeClass;
    if (activeClasses) {
      activeClasses.split(" ").forEach((cls) => {
        if (cls) this.el.classList.remove(cls);
      });
    }
  },
};

export default DragDropZone;
