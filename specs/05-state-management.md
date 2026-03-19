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

### @Store — Global Observable State

For app-wide state that any component can read and react to. Defined as an `@Observable` struct.

```swift
@Observable
struct AppState {
    var cartItems: [CartItem] = []
    var isOnboarded: Bool = false

    var cartTotal: Decimal {
        cartItems.reduce(0) { $0 + $1.price }
    }
}

// In the app root
@main
struct MyApp: App {
    @Store var appState = AppState()

    var body: some Scene {
        Routes {
            Page("/") { HomeView() }
            Page("/cart") { CartView() }
        }
        .environment(\.appState, appState)
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

`@Observable` uses Swift's observation framework. The framework tracks which properties each component reads and only re-renders components that depend on changed properties. If `CartBadge` only reads `cartItems.count`, it won't re-render when `isOnboarded` changes.

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

## Multiple Tabs / Cross-Tab Reactivity

Each browser tab is a separate WebSocket connection with its own session actor and its own `@State` tree.

**UI state (`@State`) is per-tab.** Opening a modal in tab 1 does not open it in tab 2. Each tab has independent ephemeral state.

**Database state syncs across tabs automatically.** When a database write happens (e.g., user adds an item to their cart), the server notifies all session actors for that user. Each actor re-renders its current view with the fresh data and pushes patches to its respective tab.

This works because the server already holds all session actors in memory. On a database mutation:
1. The session actor that triggered the write updates its view as normal
2. The server looks up all other active session actors for the same authenticated user
3. Each of those actors re-renders any views that depend on the changed data
4. Patches are sent to each tab's WebSocket connection

The developer doesn't think about any of this. They write to the database, and every tab showing that data updates.

## State Lifecycle

- `@State` is created when a component first appears in the view tree
- `@State` is preserved as long as the component's identity stays the same
- `@State` is destroyed when the component is removed from the view tree
- On WebSocket disconnect, all session state is destroyed
- On reconnect, the page re-renders from scratch using database state

This means: UI preferences (modal open, tab selected, scroll position) reset on reconnect. User data (profile, cart, saved items) persists because it's in the database. This is the correct behavior — ephemeral state is ephemeral, persistent state is persistent.
