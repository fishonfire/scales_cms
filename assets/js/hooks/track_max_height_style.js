/**
 * Tracks max height style for collapse delete animation in css.
 * See sortable.css .deleting class for more details.
 */
const TrackMaxHeightStyle = {
  mounted() {
    this.el.style.maxHeight = `${this.el.scrollHeight}px`;
  },

  updated() {
    if (this.el.classList.contains("deleting")) {
      this.el.style.maxHeight = undefined;
    } else {
      this.el.style.maxHeight = `${this.el.scrollHeight}px`;
    }
  },
};

export default TrackMaxHeightStyle;
