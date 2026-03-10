export default DispatchChangeOnUpdate = {
  mounted() {
    this.lastValue = this.el.value;
  },
  updated() {
    if (this.el.value !== this.lastValue) {
      this.lastValue = this.el.value;
      this.el.dispatchEvent(new Event("input", { bubbles: true }));
      this.el.dispatchEvent(new Event("change", { bubbles: true }));
    }
  },
};
