const MediaPreview = {
  mounted() {
    this.boundShowLoaded = this.showLoaded.bind(this);
    this.boundTogglePlayback = this.togglePlayback.bind(this);
    this.boundUpdatePlayButton = this.updatePlayButton.bind(this);

    this.media = null;
    this.placeholder = null;
    this.playButton = null;
    this.loaded = false;
    this.lastSource = null;

    this.bindElements();
  },

  updated() {
    const prevMedia = this.media;
    const prevPlayButton = this.playButton;
    const prevPlaceholder = this.placeholder;
    const prevSource = this.lastSource;

    this.media = this.el.querySelector("[data-media-el]");
    this.placeholder = this.el.querySelector("[data-placeholder]");
    this.playButton = this.el.querySelector("[data-play-button]");

    if (!this.media) {
      this.cleanup(prevMedia, prevPlayButton);
      this.lastSource = null;
      this.loaded = false;
      return;
    }

    const mediaChanged = prevMedia !== this.media;
    const buttonChanged = prevPlayButton !== this.playButton;
    const sourceChanged = prevSource !== this.getMediaSource(this.media);

    if (mediaChanged || buttonChanged || prevPlaceholder !== this.placeholder) {
      this.cleanup(prevMedia, prevPlayButton);
      this.loaded = false;
      this.lastSource = this.getMediaSource(this.media);
      this.setupLoading();
      this.setupPlayback();
      return;
    }

    if (sourceChanged) {
      this.cleanup(prevMedia, prevPlayButton);
      this.loaded = false;
      this.lastSource = this.getMediaSource(this.media);

      if (this.media) this.media.dataset.loaded = "false";

      if (this.media.tagName.toUpperCase() === "VIDEO") {
        this.media.load();
      }

      this.setupLoading();
      this.setupPlayback();
      return;
    }

    // LiveView may have patched classes back to opacity-0.
    if (this.isActuallyLoaded()) {
      this.showLoaded();
    }

    this.updatePlayButton();
  },

  destroyed() {
    this.cleanup(this.media, this.playButton);
  },

  bindElements() {
    this.media = this.el.querySelector("[data-media-el]");
    this.placeholder = this.el.querySelector("[data-placeholder]");
    this.playButton = this.el.querySelector("[data-play-button]");

    if (!this.media) return;

    this.lastSource = this.getMediaSource(this.media);

    this.setupLoading();
    this.setupPlayback();
  },

  getMediaSource(media) {
    if (!media) return null;

    const tag = media.tagName.toUpperCase();

    if (tag === "IMG") {
      return media.currentSrc || media.getAttribute("src");
    }

    if (tag === "VIDEO") {
      const sourceEl = media.querySelector("source");
      return (
        sourceEl?.getAttribute("src") ||
        media.currentSrc ||
        media.getAttribute("src")
      );
    }

    if (tag === "DOTLOTTIE-PLAYER") {
      return media.getAttribute("src");
    }

    return null;
  },

  isActuallyLoaded() {
    if (!this.media) return false;

    const tag = this.media.tagName.toUpperCase();

    if (tag === "IMG") {
      return this.media.complete;
    }

    if (tag === "VIDEO") {
      return this.media.readyState >= 2;
    }

    if (tag === "DOTLOTTIE-PLAYER") {
      // best-effort fallback
      return this.loaded;
    }

    return true;
  },

  cleanup(media = this.media, playButton = this.playButton) {
    if (playButton) {
      playButton.removeEventListener("click", this.boundTogglePlayback);
    }

    if (!media) return;

    const tag = media.tagName.toUpperCase();

    if (tag === "IMG") {
      media.removeEventListener("load", this.boundShowLoaded);
      media.removeEventListener("error", this.boundShowLoaded);
    }

    if (tag === "VIDEO") {
      media.removeEventListener("loadeddata", this.boundShowLoaded);
      media.removeEventListener("error", this.boundShowLoaded);
      media.removeEventListener("play", this.boundUpdatePlayButton);
      media.removeEventListener("pause", this.boundUpdatePlayButton);
      media.removeEventListener("ended", this.boundUpdatePlayButton);
    }

    if (tag === "DOTLOTTIE-PLAYER") {
      media.removeEventListener("load", this.boundShowLoaded);
      media.removeEventListener("ready", this.boundShowLoaded);
      media.removeEventListener("error", this.boundShowLoaded);
    }
  },

  setupLoading() {
    if (!this.media) return;

    const tag = this.media.tagName.toUpperCase();

    if (tag === "IMG") {
      if (this.media.complete) {
        this.showLoaded();
      } else {
        this.media.addEventListener("load", this.boundShowLoaded, {
          once: true,
        });
        this.media.addEventListener("error", this.boundShowLoaded, {
          once: true,
        });
      }
      return;
    }

    if (tag === "VIDEO") {
      if (this.media.readyState >= 2) {
        this.showLoaded();
      } else {
        this.media.addEventListener("loadeddata", this.boundShowLoaded, {
          once: true,
        });
        this.media.addEventListener("error", this.boundShowLoaded, {
          once: true,
        });
      }
      return;
    }

    if (tag === "DOTLOTTIE-PLAYER") {
      this.media.addEventListener("load", this.boundShowLoaded, { once: true });
      this.media.addEventListener("ready", this.boundShowLoaded, {
        once: true,
      });
      this.media.addEventListener("error", this.boundShowLoaded, {
        once: true,
      });
      return;
    }

    this.showLoaded();
  },

  setupPlayback() {
    if (
      !this.media ||
      !this.playButton ||
      !this.media.hasAttribute("data-playable")
    )
      return;

    this.playButton.addEventListener("click", this.boundTogglePlayback);

    if (this.media.tagName.toUpperCase() === "VIDEO") {
      this.media.addEventListener("play", this.boundUpdatePlayButton);
      this.media.addEventListener("pause", this.boundUpdatePlayButton);
      this.media.addEventListener("ended", this.boundUpdatePlayButton);
    }

    this.updatePlayButton();
  },

  showLoaded() {
    if (!this.media) return;

    this.loaded = true;
    this.media.dataset.loaded = "true";

    if (this.placeholder) {
      this.placeholder.classList.add("hidden");
    }
  },

  togglePlayback(e) {
    e.preventDefault();
    e.stopPropagation();

    if (!this.media) return;

    const tag = this.media.tagName.toUpperCase();

    if (tag === "VIDEO") {
      if (this.media.paused) {
        this.media.play().catch(() => {});
      } else {
        this.media.pause();
      }
      return;
    }

    if (tag === "DOTLOTTIE-PLAYER") {
      const isPlaying = this.media.dataset.playing === "true";

      if (isPlaying) {
        if (typeof this.media.pause === "function") this.media.pause();
        this.media.dataset.playing = "false";
      } else {
        if (typeof this.media.play === "function") this.media.play();
        this.media.dataset.playing = "true";
      }

      this.updatePlayButton();
    }
  },

  updatePlayButton() {
    if (!this.playButton || !this.media) return;

    const tag = this.media.tagName.toUpperCase();
    let isPlaying = false;

    if (tag === "VIDEO") {
      isPlaying = !this.media.paused && !this.media.ended;
    } else if (tag === "DOTLOTTIE-PLAYER") {
      isPlaying = this.media.dataset.playing === "true";
    }

    this.playButton.classList.toggle("opacity-0", isPlaying);
    this.playButton.classList.toggle("pointer-events-none", isPlaying);
  },
};

export default MediaPreview;
