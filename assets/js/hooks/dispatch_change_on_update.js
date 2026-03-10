export default DispatchChangeOnUpdate = {
  mounted() {
    console.log("Mounted");
    this.lastValue = this.el.value;
  },
  updated() {
    console.log("Value updated, dispatching change event if value has changed");
    if (this.el.value !== this.lastValue) {
      this.lastValue = this.el.value;
      this.el.dispatchEvent(new Event("input", { bubbles: true }));
      this.el.dispatchEvent(new Event("change", { bubbles: true }));
    }
  },
};
