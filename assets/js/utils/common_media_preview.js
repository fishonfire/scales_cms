const CommonMediaPreview = {
  initCommon() {
    this.media = this.el.querySelector("[data-media-el]");
    this.placeholder = this.el.querySelector("[data-placeholder]");
    this.playButton = this.el.querySelector("[data-play-button]");
  },

  showLoaded() {
    if (!this.media) return;

    this.media.dataset.loaded = "true";

    if (this.placeholder) {
      this.placeholder.classList.add("hidden");
    }
  },
};

export default CommonMediaPreview;
