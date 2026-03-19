# Architecture

## Overview

Sparrow is a server-side Swift framework that renders HTML and manages UI state on the server. The browser receives standard HTML/CSS on initial page load (for SEO and fast first paint), then establishes a WebSocket connection for real-time interactivity.

```
┌─────────────────────────────────────────────┐
│                   Browser                    │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │   DOM    │  │ Sparrow  │  │ Generated │  │
│  │ (HTML)   │  │ Client   │  │    CSS    │  │
│  │          │  │ Runtime  │  │           │  │
│  │          │  │ (~5-10KB │  │           │  │
│  │          │  │   JS)    │  │           │  │
│  └──────────┘  └────┬─────┘  └───────────┘  │
│                     │                        │
└─────────────────────┼────────────────────────┘
                      │ WebSocket
┌─────────────────────┼────────────────────────┐
│                     │       Server            │
│               ┌─────┴──────┐                  │
│               │ Hummingbird│                  │
│               │  (HTTP +   │                  │
│               │ WebSocket) │                  │
│               └─────┬──────┘                  │
│                     │                         │
│  ┌──────────────────┴───────────────────┐     │
│  │         Sparrow Runtime              │     │
│  │                                      │     │
│  │  ┌──────────┐  ┌──────────────────┐  │     │
│  │  │  Router  │  │ Session Actors   │  │     │
│  │  │          │  │                  │  │     │
│  │  │ URL →    │  │ Actor per user:  │  │     │
│  │  │ Page     │  │ - @State values  │  │     │
│  │  │ mapping  │  │ - Current view   │  │     │
│  │  │          │  │   tree           │  │     │
│  │  │          │  │ - Last rendered  │  │     │
│  │  │          │  │   HTML           │  │     │
│  │  └──────────┘  └──────────────────┘  │     │
│  │                                      │     │
│  │  ┌──────────┐  ┌──────────────────┐  │     │
│  │  │ Renderer │  │  Differ          │  │     │
│  │  │          │  │                  │  │     │
│  │  │ View →   │  │ Old HTML vs     │  │     │
│  │  │ HTML     │  │ New HTML →      │  │     │
│  │  │ string   │  │ Minimal patches │  │     │
│  │  └──────────┘  └──────────────────┘  │     │
│  └──────────────────────────────────────┘     │
│                                               │
│  ┌──────────────────────────────────────┐     │
│  │         Data Layer                   │     │
│  │  ┌───────────┐  ┌────────────────┐   │     │
│  │  │  Postgres │  │  Auth/Session  │   │     │
│  │  │  Adapter  │  │  Store         │   │     │
│  │  └───────────┘  └────────────────┘   │     │
│  └──────────────────────────────────────┘     │
└───────────────────────────────────────────────┘
```

## Request Lifecycle

### First Page Load (HTTP GET)

1. Browser requests `GET /profile/123`
2. Hummingbird receives the request
3. Sparrow router matches URL to `Page("/profile/:id")`
4. Server renders the full component tree to an HTML string
5. Server wraps it in an HTML document with:
   - The generated CSS stylesheet (`<link>`)
   - The Sparrow client JS runtime (`<script>`)
   - A session token for the WebSocket connection
6. Browser receives complete HTML — renders immediately (SEO-friendly, fast first paint)
7. Client JS runtime boots, establishes WebSocket connection using the session token
8. Server creates a Session Actor for this connection, holding the current view tree and state

### Interaction (WebSocket)

1. User clicks a button
2. Client JS captures the event, sends `{ event: "click", target: "btn_abc123" }` over WebSocket
3. Server Session Actor receives the event
4. Actor calls the event handler (e.g., `count += 1` which mutates `@State`)
5. Actor re-renders the affected component subtree
6. Differ compares previous HTML output vs. new HTML output
7. Server sends minimal DOM patches over WebSocket: `{ patches: [{ op: "replace", target: "#counter_text", html: "<p class='font-title'>Count: 2</p>" }] }`
8. Client JS applies the patches to the DOM
9. Focus, scroll position, and input values are preserved

### Navigation (WebSocket)

1. User clicks a `NavigationLink` to `/settings`
2. Client JS sends navigation event over WebSocket (does NOT do a full page load)
3. Server re-renders the new page's component tree
4. Server sends the full page content as a patch (replace the main content area)
5. Client JS patches the DOM and updates `window.history.pushState` for the URL
6. Browser URL bar shows `/settings` without a full reload
7. If the user refreshes, it's a fresh HTTP GET — SSR kicks in, same result

### Reconnection

1. WebSocket disconnects (network blip, server restart, etc.)
2. Client JS detects disconnect, shows a subtle reconnecting indicator
3. Client JS attempts reconnection with exponential backoff
4. On reconnect, server creates a new Session Actor
5. Server re-renders the current URL's page from scratch (ephemeral state is lost, database state is not)
6. Server sends full page content, client JS replaces the DOM
7. The user sees a brief flash at worst — all persistent data is intact from the database

## Internal Dependencies (Hidden from Developer)

| Dependency | Purpose | Why |
|---|---|---|
| Hummingbird | HTTP server, WebSocket, routing | Production-tested, async/await native, lightweight |
| PostgresNIO | Postgres database driver | Direct, no ORM overhead for the adapter layer |
| SwiftNIO | Underlying networking | Hummingbird depends on it |
| swift-crypto | Password hashing, session tokens | Apple's official crypto library |

The developer never imports or configures any of these. They import `Sparrow` and that's it.

## Threading Model

- Hummingbird handles HTTP/WebSocket connections on SwiftNIO's event loops
- Each user session gets a dedicated Swift Actor (`SessionActor`)
- All state mutations and re-renders for a session happen on that actor (no data races)
- Database queries are async and don't block the actor
- The renderer is a pure function: View tree in → HTML string out (no shared mutable state)
