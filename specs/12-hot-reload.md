# Hot Reload

## Overview

`sparrow run` starts a development server with automatic rebuild and browser refresh on file changes. The target is 1-3 seconds from save to seeing the update in the browser.

## How It Works

```
Developer saves file
       ↓
File watcher detects change (FSEvents on macOS)
       ↓
Incremental swift build (~1-3s for small changes)
       ↓
Server binary is restarted with new code
       ↓
Server sends "reload" signal over WebSocket to all connected browsers
       ↓
Browsers request fresh page, DOM updates
```

## File Watcher

Uses macOS FSEvents (or inotify on Linux) to watch all `.swift` files in the project directory. Ignores:
- `.build/` directory
- `Migrations/` directory (migrations don't trigger rebuild)
- Hidden files and directories

Debounces rapid file saves (200ms) to avoid multiple rebuilds when a tool saves multiple files at once.

## Incremental Compilation

Swift's incremental compilation recompiles only changed files and their dependents. For a single-file change in a small project, this is typically 1-3 seconds.

Strategies to keep it fast:
- **Module structure**: Sparrow encourages small files (one view per file) which limits the blast radius of changes
- **Separate compilation units**: The framework itself is pre-compiled; only the user's code rebuilds
- **Debug mode only**: `sparrow run` builds in debug mode (faster compilation, no optimization)

## Server Restart

On successful build:
1. The running server process receives a signal to shut down gracefully
2. Active WebSocket connections are notified with `{"type": "reloading"}`
3. The new binary starts
4. The new server re-establishes its listener on the same port
5. WebSocket clients reconnect automatically (the client runtime handles this)

The brief disconnection (< 1 second) shows the reconnecting indicator, then the page refreshes with new content.

## State During Reload

All server-side session state (`@State` values) is lost during a hot reload. This is acceptable in development:
- Database state (user data, app data) is preserved
- The page re-renders from scratch with initial state values
- For most development workflows, this is fine — you're looking at the component you just changed

## Browser Behavior

When the server sends a `{"type": "reloading"}` message:
1. Client shows a subtle "Reloading..." indicator
2. Client enters reconnection mode
3. On reconnect, client requests the current URL
4. Server renders the fresh page
5. Client replaces the DOM
6. Indicator disappears

If the build fails:
1. Server doesn't restart (old version keeps running)
2. Build errors are displayed in the terminal
3. Build errors are also sent to the browser via WebSocket: `{"type": "build_error", "errors": [...]}`
4. The browser shows a dev-only error overlay with file, line, and error message
5. When the developer fixes the error and saves, the cycle repeats

## Build Error Overlay

In development mode, build errors are shown directly in the browser:

```
┌─────────────────────────────────────────────┐
│  ✗ Build Error                              │
│                                             │
│  App.swift:15:9                             │
│  type 'User' has no member 'nme'            │
│                                             │
│  Did you mean 'name'?                       │
│                                             │
│  Waiting for changes...                     │
└─────────────────────────────────────────────┘
```

This overlay disappears automatically when the next build succeeds.

## Performance Targets

| Metric | Target | Notes |
|---|---|---|
| File change detection | < 100ms | FSEvents is near-instant |
| Incremental build (1 file changed) | 1-3s | Swift incremental compilation |
| Server restart | < 500ms | Hummingbird boots fast |
| Browser reconnect + re-render | < 500ms | WebSocket reconnection |
| **Total: save to screen update** | **2-4s** | |

## Optimization Ideas

- **Partial module reloading**: Reload only the changed view without restarting the entire server (requires Swift runtime support for dynamic loading)
- **View interpretation**: For view-only changes (no logic changes), interpret the view DSL without recompilation
- **Incremental CSS**: Only regenerate CSS for changed components
- **State preservation**: Serialize and restore `@State` across reloads in dev mode
