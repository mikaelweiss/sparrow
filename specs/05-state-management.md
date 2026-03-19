# State Management

## Overview

State management in Sparrow follows the SwiftUI model: property wrappers declare how state is owned and shared. The framework handles reactivity automatically — change a value, the UI updates.

All state lives on the server in a per-session Swift Actor. The developer never thinks about client/server synchronization, serialization, or WebSocket plumbing.

## State Tiers

### @State — Component-Local State

Owned by a single component. Mutable. Triggers a re-render of the component when changed.

```swift
struct Counter: View {
    @State var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
                .font(.title)
            Button("Increment") {
                count += 1
            }
        }
    }
}
```

When `count` changes:
1. The Session Actor updates the value
2. Re-renders `Counter`'s body
3. Diffs the HTML output
4. Sends the patch over WebSocket
5. Browser DOM updates

### @Binding — Two-Way Reference to Parent State

A reference to state owned by a parent. The child can read and write it. Changes propagate back to the parent and trigger re-renders of both.

```swift
struct ToggleRow: View {
    var label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(label)
            Toggle("", isOn: $isOn)
        }
    }
}

struct SettingsView: View {
    @State var notificationsEnabled = true

    var body: some View {
        ToggleRow(label: "Notifications", isOn: $notificationsEnabled)
    }
}
```

The `$` prefix passes a binding rather than a copy.

### @Environment — Injected Values from Ancestors

Read-only values injected into the environment, accessible by any descendant. Used for theme, auth state, app-wide settings.

```swift
struct ProfileView: View {
    @Environment(\.currentUser) var user
    @Environment(\.theme) var theme
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text(user.name)
            .font(.title)
    }
}
```

Setting environment values:

```swift
MyView()
    .environment(\.currentUser, user)
```

Environment values propagate down the tree. Any descendant can read them. Setting a value on a subtree overrides the ancestor's value for that subtree only (just like SwiftUI).

### @Observable — Shared State

For app-wide state that multiple components can read and react to. Uses Swift's Observation framework directly — no extra property wrapper needed.

```swift
@Observable
class AppState {
    var cartItems: [CartItem] = []
    var isOnboarded: Bool = false

    var cartTotal: Decimal {
        cartItems.reduce(0) { $0 + $1.price }
    }
}

// In the app root — just inject via @Environment
@main
struct MyApp: App {
    var body: some Scene {
        Routes {
            Page("/") { HomeView() }
            Page("/cart") { CartView() }
        }
        .environment(\.appState, AppState())
    }
}

// Any component can read it
struct CartBadge: View {
    @Environment(\.appState) var appState

    var body: some View {
        Badge("\(appState.cartItems.count)")
    }
}
```

The framework tracks which properties each component reads and only re-renders components that depend on changed properties. If `CartBadge` only reads `cartItems.count`, it won't re-render when `isOnboarded` changes.

There is no `@Store` wrapper. `@Observable` + `@Environment` covers this case. Fewer wrappers = less confusion. This is the lesson SwiftUI learned when it collapsed `@StateObject`/`@ObservedObject`/`@EnvironmentObject` into `@Observable`.

**Guidelines for `@Observable` types:**
- Keep them small and focused. One model per domain concern, not a god object.
- Observation of items inside arrays has known sharp edges. If a view reads `items[i].name`, mutations to `items[i].name` must go through the `@Observable` tracking to trigger re-renders. Prefer flat data over deeply nested observable graphs.
- `@Observable` requires `class`, not `struct`. This is intentional — shared mutable state needs reference semantics.

## Derived State

Computed properties on `@State` or `@Observable` types:

```swift
struct SearchView: View {
    @State var searchText = ""
    @State var allItems: [Item] = []

    var filteredItems: [Item] {
        if searchText.isEmpty { return allItems }
        return allItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
            ForEach(filteredItems) { item in
                ItemRow(item: item)
            }
        }
    }
}
```

No special annotation needed. `filteredItems` recomputes when `searchText` or `allItems` changes (because re-render recomputes the body).

## Async State

For data fetched from the database or external APIs.

```swift
struct UserListView: View {
    @State var users: [User] = []
    @State var loadState: LoadState = .idle

    var body: some View {
        switch loadState {
        case .idle, .loading:
            Spinner()
        case .loaded:
            ForEach(users) { user in
                UserRow(user: user)
            }
        case .error(let message):
            ErrorBanner(message: message)
        }
    }
    .task {
        loadState = .loading
        do {
            users = try await User.query().all()
            loadState = .loaded
        } catch {
            loadState = .error(error.localizedDescription)
        }
    }
}
```

The `.task` modifier launches async work when the view appears and cancels it when the view disappears.

### AsyncView Shorthand

For the common pattern of "load data, show spinner, show result":

```swift
struct UserListView: View {
    var body: some View {
        AsyncView(load: { try await User.query().all() }) { users in
            ForEach(users) { user in
                UserRow(user: user)
            }
        }
    }
}
```

`AsyncView` automatically shows a `Spinner` while loading, an `ErrorBanner` on failure, and the content on success. The loading/error views are customizable.

## LoadState Enum

A built-in algebraic type for async state:

```swift
enum LoadState {
    case idle
    case loading
    case loaded
    case error(String)
}
```

The compiler enforces exhaustive handling in `switch` statements — you can't forget the error case.

## Session Actor Internals

Each WebSocket connection gets a `SessionActor`:

```swift
actor SessionActor {
    let sessionId: String
    var viewTree: any View          // current rendered view hierarchy
    var stateStore: StateStore      // all @State values for this session
    var lastRenderedHTML: String     // previous render output for diffing
    var environment: EnvironmentValues  // environment chain

    func handleEvent(_ event: ClientEvent) async {
        // 1. Find the target component
        // 2. Execute the event handler (which may mutate @State)
        // 3. Re-render affected components
        // 4. Diff against lastRenderedHTML
        // 5. Send patches to client
    }
}
```

State is identified by component identity (position in the view tree + any explicit `id`). This matches SwiftUI's state identity model.

### Session Memory Management

Every concurrent WebSocket connection holds state in server memory. This is the fundamental scalability constraint of the LiveView model. A baseline connection is cheap (~40KB), but real applications store view trees, state values, and data in each session.

**Rules:**
- **Keep session assigns minimal.** The session actor should hold only what is needed to render the current view. Shared data (e.g., product catalog, user lists) should live in a shared cache or the database, not copied into every session.
- **Large collections must use temporary assigns or streams.** If a view renders 10,000 rows, the session must not hold all 10,000 in memory after the render. Temporary assigns are freed after rendering — the HTML is already generated, the data is no longer needed. Streams handle append-only data (chat messages, logs) without growing memory.
- **Throttle broadcasts.** When notifying sessions of database changes (see Cross-Tab Reactivity below), send small signals, not full payloads. Each session fetches what it needs.

The framework should provide `temporaryAssign` and `stream` primitives so developers don't have to think about this — but the defaults must be safe. If a developer puts a large list in `@State`, the framework should warn or automatically treat it as temporary after render.

## Multiple Tabs / Cross-Tab Reactivity

Each browser tab is a separate WebSocket connection with its own session actor and its own `@State` tree.

**UI state (`@State`) is per-tab.** Opening a modal in tab 1 does not open it in tab 2. Each tab has independent ephemeral state.

**Database state syncs across tabs automatically.** When a database write happens (e.g., user adds an item to their cart), the server notifies all session actors for that user. Each actor re-renders its current view with the fresh data and pushes patches to its respective tab.

This works because the server already holds all session actors in memory. On a database mutation:
1. The session actor that triggered the write updates its view as normal
2. The server broadcasts a lightweight signal (not the full data) to other active session actors for the same user
3. Each notified actor fetches the changed data it needs and re-renders affected views
4. Patches are sent to each tab's WebSocket connection

The developer doesn't think about any of this. They write to the database, and every tab showing that data updates.

**Important:** Never broadcast full data payloads to all sessions. A naive implementation that sends the entire updated dataset to N sessions multiplies memory by N. Send a signal ("cart changed"), let each session fetch what it needs.

## State Lifecycle

- `@State` is created when a component first appears in the view tree
- `@State` is preserved as long as the component's identity stays the same
- `@State` is destroyed when the component is removed from the view tree
- On WebSocket disconnect, all session state is destroyed
- On reconnect, the page re-renders from scratch using database state

This means: UI preferences (modal open, tab selected, scroll position) reset on reconnect. User data (profile, cart, saved items) persists because it's in the database. This is the correct behavior — ephemeral state is ephemeral, persistent state is persistent.

### Surviving Reconnects

State loss on disconnect (crash, deploy, network blip) is inherent to the server-state model. To minimize user-visible disruption:

- **Navigational state goes in the URL.** Active tab, pagination, filters, sort order — these must be URL parameters, not `@State`. This way they survive reconnects and support the back button.
- **Form inputs auto-recover.** The client runtime should snapshot form field values and replay them on reconnect. Phoenix LiveView does this and it works well.
- **Accept the reset for everything else.** A modal closing or an accordion collapsing on reconnect is fine. Do not try to persist all UI state — the complexity is not worth it.

## Latency and Client-Side Escape Hatch

Every user interaction round-trips to the server. At <50ms latency this is invisible. At 100ms+ it's noticeable. At 250ms+ it degrades the experience for fast interactions like toggles, dropdowns, and text formatting.

The framework's position is "zero JS written by the developer," and that should remain the default path. But the spec must acknowledge reality: some interactions cannot tolerate a round-trip.

**Approach:** Provide a `clientSide` modifier or JS hooks system for developers who need zero-latency interactions. The developer writes a small JS snippet that handles the immediate UI feedback, and the server still processes the authoritative state change.

```swift
Toggle("Dark mode", isOn: $darkMode)
    .clientHint(.toggle)  // client toggles immediately, server confirms
```

This is not a contradiction of the framework's philosophy — it's the same pattern every successful LiveView framework converges on (Phoenix hooks, Livewire's `wire:model.live` vs `wire:model.blur`, Alpine.js integration). Ship the escape hatch from day one rather than bolting it on later.

## Offline

Sparrow apps do not work offline. This is inherent to the architecture and not a bug. If the WebSocket disconnects, the app shows a reconnecting state and resumes when the connection returns. Do not attempt to build offline support — it contradicts the server-state model. Be honest about this in documentation.
