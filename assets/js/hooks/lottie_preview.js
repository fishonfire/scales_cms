import CommonMediaPreview from "../utils/common_media_preview";

const LottiePreview = {
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
      this.bind(next);
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
      player: this.getPlayer(this.media),
    };
  },

  isSameBinding(a, b) {
    return (
      a?.media === b.media &&
      a?.playButton === b.playButton &&
      a?.placeholder === b.placeholder &&
      a?.src === b.src &&
      a?.player === b.player
    );
  },

  bind(binding) {
    const { media, playButton, player } = binding;
    if (!media) return;

    media.dataset.loaded = "false";
    media.dataset.playing = "false";

    this.bindLoading(player);
    this.bindPlayback(media, playButton);
  },

  bindLoading(player) {
    if (!player) return;

    player.addEventListener("ready", this.onLoaded, { once: true });
    player.addEventListener("loadError", this.onLoaded, { once: true });
  },

  bindPlayback(media, playButton) {
    if (!media || !playButton || !media.hasAttribute("data-playable")) return;

    playButton.addEventListener("click", this.onTogglePlayback);
    this.updatePlayButton();
  },

  togglePlayback(e) {
    e.preventDefault();
    e.stopPropagation();

    const media = this.binding?.media;
    const player = this.binding?.player;

    if (!media || !player) return;

    const isPlaying = media.dataset.playing === "true";

    if (isPlaying) {
      player.pause?.();
      media.dataset.playing = "false";
    } else {
      player.play?.();
      media.dataset.playing = "true";
    }

    this.updatePlayButton();
  },

  updatePlayButton() {
    const media = this.binding?.media;
    const playButton = this.binding?.playButton;

    if (!media || !playButton) return;

    const isPlaying = media.dataset.playing === "true";
    playButton.classList.toggle("opacity-0", isPlaying);
    playButton.classList.toggle("pointer-events-none", isPlaying);
  },

  unbind(binding = this.binding) {
    const media = binding?.media;
    const playButton = binding?.playButton;
    const player = binding?.player;

    if (playButton) {
      playButton.removeEventListener("click", this.onTogglePlayback);
    }

    if (!player) return;

    player.removeEventListener("ready", this.onLoaded);
    player.removeEventListener("loadError", this.onLoaded);
  },

  getSource(media) {
    return media?.getAttribute("src") || null;
  },

  getPlayer(media) {
    return media?.dotLottie || null;
  },
};

export default LottiePreview;
