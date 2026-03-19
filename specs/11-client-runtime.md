# Client Runtime

## Overview

Sparrow ships a small JavaScript runtime (~5-10KB minified+gzipped) that runs in the browser. The developer never sees, writes, or configures it. It handles WebSocket connections, DOM patching, event forwarding, and navigation.

## Responsibilities

1. **WebSocket connection management** — connect, reconnect, heartbeat
2. **DOM patching** — apply server-sent patches to the live DOM
3. **Event capture** — detect user interactions and forward to server
4. **Navigation** — handle client-side navigation without full page reloads
5. **Focus management** — preserve focus state after DOM patches
6. **Scroll preservation** — maintain scroll position during updates
7. **Input state** — preserve in-progress input values during re-renders
8. **Reconnection UI** — show/hide reconnecting indicator

## WebSocket Protocol

### Connection

On page load, after the SSR HTML is rendered:

```javascript
Sparrow.connect("ws://localhost:3000/sparrow/ws", "session_token");
```

The session token is embedded in the SSR HTML by the server. It identifies the session actor on the server.

### Message Format

All messages are JSON over WebSocket.

**Client → Server:**

```json
// User events
{"type": "event", "id": "v_0_2", "event": "click"}
{"type": "event", "id": "v_0_3", "event": "input", "value": "hello"}
{"type": "event", "id": "v_form", "event": "submit", "values": {"email": "a@b.com"}}

// Navigation
{"type": "navigate", "url": "/settings"}

// Heartbeat
{"type": "ping"}
```

**Server → Client:**

```json
// DOM patches
{"type": "patch", "patches": [
    {"op": "text", "target": "#v_0_1", "value": "Count: 2"},
    {"op": "replace", "target": "#v_0_2", "html": "<div>...</div>"}
]}

// Full page replacement (navigation)
{"type": "page", "html": "<div id='sparrow-root'>...</div>", "url": "/settings", "title": "Settings"}

// Heartbeat response
{"type": "pong"}
```

### Reconnection

1. WebSocket `onclose` fires
2. Client shows a small, non-intrusive reconnecting indicator (bottom of screen)
3. Reconnect attempts with exponential backoff: 100ms, 200ms, 400ms, 800ms, 1.6s, 3.2s, max 5s
4. On successful reconnect, client sends `{"type": "reconnect", "url": window.location.pathname}`
5. Server creates a new session actor, renders the current URL, sends full page content
6. Client replaces the DOM and removes the reconnecting indicator

If reconnection fails after 30 seconds, the client shows a "Connection lost. Click to retry." message.

## DOM Patching

The client applies patches sequentially. Each patch targets a DOM element by its `id` attribute.

```javascript
// Simplified patch application
function applyPatch(patch) {
    const el = document.getElementById(patch.target.replace('#', ''));
    switch (patch.op) {
        case 'text':
            el.textContent = patch.value;
            break;
        case 'replace':
            el.outerHTML = patch.html;
            break;
        case 'remove':
            el.remove();
            break;
        case 'append':
            el.insertAdjacentHTML('beforeend', patch.html);
            break;
        case 'prepend':
            el.insertAdjacentHTML('afterbegin', patch.html);
            break;
        case 'attr':
            el.setAttribute(patch.attr, patch.value);
            break;
        case 'reorder':
            // Reorder children by id list
            break;
    }
}
```

### Focus Preservation

Before applying patches, the client records:
- The currently focused element's ID
- The cursor position within text inputs
- Selection range

After applying patches, if the focused element still exists, focus and cursor position are restored.

### Scroll Preservation

Scroll position of the page and any scrollable containers is recorded before patches and restored after, unless the patch is a full page navigation (in which case scroll resets to top).

### Input Value Preservation

If a text input is currently being edited and a patch arrives for its parent (but not the input itself), the input's value is preserved. This prevents the common problem where a server re-render wipes out a user's in-progress typing.

## Event Capture

The client uses event delegation on `#sparrow-root`:

```javascript
root.addEventListener('click', (e) => {
    const target = e.target.closest('[data-sparrow-event*="click"]');
    if (target) {
        e.preventDefault();
        send({ type: 'event', id: target.id, event: 'click' });
    }
});
```

### Captured Events

| Event | Trigger | Data Sent |
|---|---|---|
| `click` | Button, link, any clickable | `{id, event: "click"}` |
| `input` | Text field, text area | `{id, event: "input", value}` (debounced) |
| `change` | Toggle, picker, checkbox | `{id, event: "change", value}` |
| `submit` | Form submission | `{id, event: "submit", values: {field: value, ...}}` |
| `focus` | Element receives focus | `{id, event: "focus"}` |
| `blur` | Element loses focus | `{id, event: "blur"}` |

### Debouncing

Text inputs are debounced to avoid sending every keystroke:

```html
<input data-sparrow-event="input" data-sparrow-debounce="300">
```

The default debounce is 300ms. The developer controls this with `.debounce()` on the Swift side. The value is emitted as a `data-sparrow-debounce` attribute.

## Navigation

### Internal Links

`<a>` tags with `data-sparrow-nav` are intercepted:

```javascript
root.addEventListener('click', (e) => {
    const link = e.target.closest('a[data-sparrow-nav]');
    if (link) {
        e.preventDefault();
        const url = link.getAttribute('href');
        send({ type: 'navigate', url });
        window.history.pushState({}, '', url);
    }
});
```

The server responds with a `page` message containing the new content. The client replaces the content area and updates the document title.

### Browser Back/Forward

```javascript
window.addEventListener('popstate', () => {
    send({ type: 'navigate', url: window.location.pathname });
});
```

### External Links

Regular `<a href="https://...">` links without `data-sparrow-nav` work normally — the browser handles them.

## Loading States

When an event is sent and the server hasn't responded yet, the client can show loading states:

- Buttons that triggered the event get a `data-sparrow-loading` attribute (which the CSS uses to show a spinner or disable the button)
- The loading state is automatically cleared when the server responds with patches

```html
<!-- Server sends this attribute in the HTML -->
<button data-sparrow-loading-class="btn-loading">Submit</button>
```

When the button is clicked and waiting for a server response, the client adds the `btn-loading` class. When the response arrives, it's removed (or the button is replaced entirely by the patch).

## Size Budget

Target: **under 10KB minified + gzipped**.

The runtime is intentionally minimal:
- No virtual DOM
- No client-side state management
- No template engine
- No routing logic (server handles it)
- Just: WebSocket + DOM patching + event forwarding + navigation

For comparison: HTMX is ~14KB, Alpine.js is ~7KB. Sparrow's runtime is in the same ballpark but more focused.
