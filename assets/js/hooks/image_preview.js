import CommonMediaPreview from "../utils/common_media_preview";

const ImagePreview = {
  initCommon: CommonMediaPreview.initCommon,
  showLoaded: CommonMediaPreview.showLoaded,

  mounted() {
    this.bindHandlers();
    this.sync();
  },

  updated() {
    this.sync();
  },

  destroyed() {
    this.unbind();
  },

  bindHandlers() {
    this.onLoaded = () => this.showLoaded();
  },

  sync() {
    const prev = this.binding;
    this.initCommon();

    const next = this.createBinding();

    if (!next.media) {
      this.unbind(prev);
      this.binding = next;
      return;
    }

    if (!this.isSameBinding(prev, next)) {
      this.unbind(prev);
      this.bind(next);
      this.binding = next;
    }
  },

  createBinding() {
    return {
      media: this.media || null,
      placeholder: this.placeholder || null,
      src: this.getSource(this.media),
    };
  },

  isSameBinding(a, b) {
    return (
      a?.media === b.media &&
      a?.placeholder === b.placeholder &&
      a?.src === b.src
    );
  },

  bind(binding) {
    const { media } = binding;
    if (!media) return;

    media.dataset.loaded = "false";
    this.bindLoading(media);
  },

  bindLoading(media) {
    if (media.complete) {
      this.showLoaded();
      return;
    }

    media.addEventListener("load", this.onLoaded, { once: true });
    media.addEventListener("error", this.onLoaded, { once: true });
  },

  unbind(binding = this.binding) {
    const media = binding?.media;
    if (!media) return;

    media.removeEventListener("load", this.onLoaded);
    media.removeEventListener("error", this.onLoaded);
  },

  getSource(media) {
    if (!media) return null;
    return media.currentSrc || media.getAttribute("src");
  },
};

export default ImagePreview;
