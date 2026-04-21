const CMSComponentAnimator = {
  mounted() {
    this.setInitialHeight();
    this.maybeAnimateIn();
  },

  updated() {
    if (this.el.classList.contains("deleting")) {
      // Let CSS handle collapse-out
      this.el.style.maxHeight = null;
      return;
    }

    this.maybeAnimateIn();
  },

  setInitialHeight() {
    // Keep max height big so that it always takes up all space it needs.
    this.el.style.maxHeight = `99999px`;
  },

  maybeAnimateIn() {
    if (this.el.dataset.animateIn !== "true") return;
    if (this.el.dataset.animated === "true") return;

    this.el.dataset.animated = "true";

    const el = this.el;
    const ghostHeight = parseFloat(el.dataset.ghostHeight);
    const startHeight = ghostHeight || 0;

    // Start collapsed
    el.style.maxHeight = `${startHeight}px`;
    el.style.opacity = "0";

    // Force reflow so browser applies initial state
    el.getBoundingClientRect();

    // Animate to full height
    el.style.transition =
      "max-height 250ms ease, opacity 200ms ease, transform 250ms ease";
    el.style.maxHeight = `${el.scrollHeight}px`;
    el.style.opacity = "1";

    const cleanup = () => {
      el.style.maxHeight = null; // remove the fixed cap so future content growth is not clipped
      el.removeEventListener("transitionend", cleanup);
    };

    el.addEventListener("transitionend", cleanup);
  },
};

export default CMSComponentAnimator;
