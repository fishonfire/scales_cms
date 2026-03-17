import CommonMediaPreview from "../utils/common_media_preview";

const PLAYBACK_EVENTS = ["play", "pause", "ended"];

const VideoPreview = {
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
    this.onLoaded = () => {
      this.showLoaded();
      this.updatePlayButton();
    };
    this.onPlayStateChange = () => this.updatePlayButton();
    this.onTogglePlayback = (e) => this.togglePlayback(e);
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
      this.bind(next, prev);
      this.binding = next;
      return;
    }

    this.updatePlayButton();
  },

  createBinding() {
    return {
      media: this.media || null,
      playButton: this.playButton || null,
      placeholder: this.placeholder || null,
      src: this.getSource(this.media),
    };
  },

  isSameBinding(a, b) {
    return (
      a?.media === b.media &&
      a?.playButton === b.playButton &&
      a?.placeholder === b.placeholder &&
      a?.src === b.src
    );
  },

  bind(binding, prev) {
    const { media, playButton, src } = binding;
    if (!media) return;

    media.dataset.loaded = "false";

    const srcChanged = prev?.src !== src;
    if (srcChanged && media.tagName.toUpperCase() === "VIDEO") {
      media.load();
    }

    this.bindLoading(media);
    this.bindPlayback(media, playButton);
  },

  bindLoading(media) {
    if (media.readyState >= 2) {
      this.showLoaded();
      return;
    }

    media.addEventListener("loadeddata", this.onLoaded, { once: true });
    media.addEventListener("error", this.onLoaded, { once: true });
  },

  bindPlayback(media, playButton) {
    if (!playButton || !media.hasAttribute("data-playable")) return;

    playButton.addEventListener("click", this.onTogglePlayback);

    PLAYBACK_EVENTS.forEach((eventName) => {
      media.addEventListener(eventName, this.onPlayStateChange);
    });

    this.updatePlayButton();
  },

  togglePlayback(e) {
    e.preventDefault();
    e.stopPropagation();

    const media = this.binding?.media;
    if (!media) return;

    if (media.paused) {
      media.play().catch(() => {});
    } else {
      media.pause();
    }
  },

  updatePlayButton() {
    const media = this.binding?.media;
    const playButton = this.binding?.playButton;

    if (!media || !playButton) return;

    const isPlaying = !media.paused && !media.ended;
    playButton.classList.toggle("opacity-0", isPlaying);
    playButton.classList.toggle("pointer-events-none", isPlaying);
  },

  unbind(binding = this.binding) {
    const media = binding?.media;
    const playButton = binding?.playButton;

    if (playButton) {
      playButton.removeEventListener("click", this.onTogglePlayback);
    }

    if (!media) return;

    media.removeEventListener("loadeddata", this.onLoaded);
    media.removeEventListener("error", this.onLoaded);

    PLAYBACK_EVENTS.forEach((eventName) => {
      media.removeEventListener(eventName, this.onPlayStateChange);
    });
  },

  getSource(media) {
    if (!media) return null;

    const sourceEl = media.querySelector("source");
    return (
      sourceEl?.getAttribute("src") ||
      media.currentSrc ||
      media.getAttribute("src")
    );
  },
};

export default VideoPreview;
