# Persisting UI State (ETS + Session)

Scales CMS provides a generic mechanism to persist UI state across:

- **LiveView navigations** (via ETS)
- **Full page reloads** (via Plug session)

This allows you to easily maintain things like:

- Sidebar open/closed state
- Panel visibility
- Selected tabs
- Layout preferences

---

## How It Works

State persistence is handled through a **two-layer system**:

### 1. ETS (in-memory)

- Fast access
- Persists across LiveView navigation and reconnects

### 2. Session (Plug session)

- Persists across full page reloads
- Synced via an HTTP endpoint

---

## State Flow

### Initialization

State is initialized from:

1. ETS (if available)
2. Session
3. Default value

### Updates

When state changes:

- Update LiveView assign
- Store in ETS
- Persist to session via HTTP call

---

## Enabling Persisted State

Persisted state is configured via a LiveView `on_mount` hook.

### Router Setup

Persistence is part of the global router setup and is automatically available in CMS LiveViews.

---

## Options

- `:name` — atom used in assigns (`:sidebar_open`)
- `:session_key` — string used in session (`"sidebar_open"`)
- `:default` — fallback value
- `:normalize` *(optional)* — function to coerce values

---

## Using Persisted State in LiveView

Once configured, the state is available directly on the socket:

```elixir
socket.assigns.sidebar_open
```

---

## Updating State

### 1. From the Client (Recommended for UI interactions)

```elixir
push_event(socket, "update_persisted_state", %{
  "name" => "sidebar_open",
  "value" => false
})
```

### 2. From the Server

```elixir
send(self(), {:update_persisted_state, :sidebar_open, false})
```

### What Both Approaches Do

- Update the LiveView assign
- Store the value in ETS
- Trigger persistence to session (via client hook)

---

## Persisting to Session (HTTP Layer)

Because LiveView cannot directly write to the session, a controller is used.

### Endpoint

```http
POST /ui/state
```

### Expected Payload

```json
{ "name": "sidebar_open", "value": true }
```

### Controller Behavior

- Validates allowed state keys
- Stores value in session
- Returns `204 No Content`

---

## Client-Side Hook

A small JS hook is responsible for persisting state changes:

```js
this.handleEvent("persisted-state-changed", ({ name, value }) => {
  this.persistState(name, value);
});
```

### Request

```js
fetch("/ui/state", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "x-csrf-token": csrfToken,
  },
  body: JSON.stringify({ name, value }),
});
```

> **Note:** Persistence is non-blocking — UI state updates immediately even if the request fails.

---

## Adding Custom Persisted States

You can define additional states via config:

```elixir
config :scales_cms,
  custom_persistence_states: [:filters_open, :drawer_open]
```

These will automatically be:

- Added to the `on_mount` hook
- Allowed by the controller

---

## ETS Storage

All state is stored in a shared ETS table:

```elixir
:persisted_state_store
```

### Started via

```elixir
ScalesCmsWeb.PersistedStateStore
```

---

## Key Structure

```text
"<scope>:<name>"
```

### Scope

- **Authenticated users:** `"user:<id>"`
- **Anonymous users:** socket-based ID

### Result

- State is shared across tabs for logged-in users
- State is isolated per session for anonymous users

---

## Manual ETS Access (Advanced)

You can interact with persisted state manually:

```elixir
ScalesCmsWeb.Hooks.PersistedState.get_state(scope, :sidebar_open, true)

ScalesCmsWeb.Hooks.PersistedState.update_state(scope, :sidebar_open, false)
```

### Getting the Correct Scope

```elixir
ScalesCmsWeb.Hooks.PersistedState.stable_scope(socket)
```

---

## Notes & Best Practices

- Always use **boolean values** for UI toggles
- Keep state names consistent (`sidebar_open`, not `sidebarOpen`)
- Prefer **client-driven updates** (`push_event`) for UI interactions
- Use **ETS for performance**, session for durability
- Treat persistence as **eventually consistent**, not critical
