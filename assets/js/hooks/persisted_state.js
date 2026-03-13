/**
 * PersistedState Hook
 *
 * Manages state persistence to the server session.
 *
 * The initial sidebar state is rendered server-side from session data,
 * so there's no need for client-side state correction on page load.
 * This hook simply persists state changes back to the server.
 *
 * ## Flow
 *
 * 1. Server renders correct initial state (open/closed class) based on session
 * 2. When user toggles sidebar, LiveView pushes "sidebar-state-changed" event
 * 3. Hook catches event and POSTs to /ui/sidebar to persist to session
 * 4. On next page load, server reads from session and renders correct state
 */
const PersistedState = {
  mounted() {
    // Listen for sidebar state changes from the server
    // and persist to session via AJAX
    this.handleEvent("persisted-state-changed", ({ name, value }) => {
      this.persistState(name, value);
    });
  },

  /**
   * Persist sidebar state to the server session via AJAX.
   *
   * @param {string} name - The name of the state being persisted (e.g., "sidebarOpen")
   * @param {any} value - The value of the state to persist (e.g., true/false)
   */
  persistState(name, value) {
    const csrfToken = document
      .querySelector("meta[name='csrf-token']")
      ?.getAttribute("content");

    if (!csrfToken) {
      console.error("SidebarState: CSRF token not found");
      return;
    }

    fetch("/ui/state", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-csrf-token": csrfToken,
      },
      body: JSON.stringify({ value }),
    }).catch((error) => {
      // Log but don't throw - sidebar state persistence is non-critical
      // The UI already reflects the correct state; this is just for persistence
      console.error("PersistedState: Failed to persist state", error);
    });
  },
};

export default PersistedState;
