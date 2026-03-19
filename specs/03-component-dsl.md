# Component DSL

## Overview

Sparrow's UI is built with a SwiftUI-like declarative DSL. Components are Swift structs conforming to the `View` protocol. They compose using result builders and modify with chainable modifiers.

## The View Protocol

```swift
protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}
```

Every component implements `body` and returns other views. The framework provides primitive views (Text, Image, etc.) that render directly to HTML. User-defined views compose these primitives.

## Basic Example

```swift
struct ProfileCard: View {
    var user: User

    var body: some View {
        VStack(spacing: 12) {
            Image(url: user.avatarURL)
                .frame(width: 64, height: 64)
                .cornerRadius(.full)
            Text(user.name)
                .font(.title)
                .foreground(.primary)
            if user.isVerified {
                Badge("Verified", style: .success)
            }
        }
        .padding(16)
        .background(.surface)
        .cornerRadius(.md)
        .shadow(.sm)
    }
}
```

## Result Builders

The `@ViewBuilder` result builder enables SwiftUI-like syntax:

```swift
// if/else
if isLoggedIn {
    DashboardView()
} else {
    LoginView()
}

// for loops
ForEach(users) { user in
    UserRow(user: user)
}

// optional views
if let error = errorMessage {
    ErrorBanner(message: error)
}
```

## Primitive Views

### Layout

| View | HTML Output | Purpose |
|---|---|---|
| `VStack(alignment:spacing:)` | `<div>` with flex column | Vertical stack |
| `HStack(alignment:spacing:)` | `<div>` with flex row | Horizontal stack |
| `ZStack(alignment:)` | `<div>` with position relative/absolute | Overlapping layers |
| `Spacer()` | `<div>` with flex-grow | Flexible space |
| `Divider()` | `<hr>` | Visual separator |
| `ScrollView(axis:)` | `<div>` with overflow scroll | Scrollable container |
| `Grid(columns:spacing:)` | `<div>` with CSS grid | 2D grid layout |

### Text & Labels

| View | HTML Output | Purpose |
|---|---|---|
| `Text(_ string:)` | `<p>`, `<span>`, `<h1>`-`<h6>` depending on context | Display text |
| `Label(_ title:icon:)` | `<span>` with icon + text | Icon-text pair |
| `Markdown(_ string:)` | Rendered markdown → HTML | Markdown content |

`Text` renders as `<h1>`-`<h6>` when a `.font(.title)` through `.font(.title3)` modifier is applied. Otherwise renders as `<p>` for block context or `<span>` for inline context.

### Input

| View | HTML Output | Purpose |
|---|---|---|
| `Button(_ title:action:)` | `<button>` | Clickable button |
| `TextField(_ placeholder:text:)` | `<input type="text">` | Single-line text input |
| `SecureField(_ placeholder:text:)` | `<input type="password">` | Password input |
| `TextEditor(text:)` | `<textarea>` | Multi-line text input |
| `Toggle(_ label:isOn:)` | `<input type="checkbox">` styled as toggle | Boolean toggle |
| `Picker(_ label:selection:)` | `<select>` | Selection from options |
| `Slider(value:in:step:)` | `<input type="range">` | Numeric slider |
| `DatePicker(_ label:selection:)` | `<input type="date">` | Date selection |

### Media

| View | HTML Output | Purpose |
|---|---|---|
| `Image(_ name:)` | `<img>` | Display image from assets |
| `Image(url:)` | `<img>` with src URL | Display remote image |
| `Icon(_ systemName:)` | `<svg>` from built-in icon set | System icon |

### Navigation

| View | HTML Output | Purpose |
|---|---|---|
| `NavigationLink(_ title:destination:)` | `<a>` with WebSocket navigation | Internal navigation |
| `Link(_ title:url:)` | `<a>` with href | External link |

### Containers

| View | HTML Output | Purpose |
|---|---|---|
| `List(items:)` | `<ul>` / `<ol>` | Styled list |
| `Form(content:)` | `<form>` | Form container with built-in validation |
| `Section(header:)` | `<section>` with header | Grouped content |
| `Card(content:)` | `<div>` with surface styling | Card container |
| `Modal(isPresented:)` | `<dialog>` | Modal overlay |
| `Sheet(isPresented:)` | `<div>` with slide-in animation | Bottom/side sheet |
| `Menu(_ label:)` | `<div>` with dropdown | Dropdown menu |

### Feedback

| View | HTML Output | Purpose |
|---|---|---|
| `Alert(title:message:actions:)` | `<div role="alert">` | Alert dialog |
| `Toast(message:style:)` | `<div>` with position fixed | Temporary notification |
| `Badge(_ text:style:)` | `<span>` | Status badge |
| `ProgressView(value:total:)` | `<progress>` | Progress indicator |
| `Spinner()` | `<div>` with CSS animation | Loading spinner |

## Modifiers

Modifiers are chainable methods that return a modified view. They map to CSS classes from the design system.

### Spacing

```swift
.padding(16)                    // all sides
.padding(.horizontal, 16)      // left + right
.padding(.top, 8)              // single side
.margin(16)                     // outer spacing
```

### Typography

```swift
.font(.largeTitle)              // preset font style
.font(.system(size: 18, weight: .semibold))  // custom
.foreground(.primary)           // text color (semantic)
.foreground(.hex("#FF0000"))    // text color (explicit)
.multilineTextAlignment(.center)
.lineLimit(3)
.truncationMode(.tail)
```

### Background & Borders

```swift
.background(.surface)           // semantic color
.background(.hex("#F5F5F5"))    // explicit color
.cornerRadius(.md)              // from design system scale
.cornerRadius(12)               // explicit pixels
.border(.secondary, width: 1)
.shadow(.sm)                    // from design system scale
```

### Layout

```swift
.frame(width: 200, height: 100)
.frame(maxWidth: .infinity)     // expand to fill
.frame(minHeight: 44)           // minimum tap target
.aspectRatio(16/9)
.opacity(0.5)
.hidden()                       // display: none
.zIndex(10)
```

### Interaction

```swift
.onClick { /* handler */ }
.onSubmit { /* handler */ }
.onAppear { /* handler */ }
.onDisappear { /* handler */ }
.task { await loadData() }          // async work on appear
.disabled(isLoading)
.cursor(.pointer)
```

### Async Work

The `.task` modifier launches async work when a view appears. It's the primary way to load data:

```swift
struct UserListView: View {
    @State var users: [User] = []

    var body: some View {
        ForEach(users) { user in
            Text(user.name)
        }
        .task {
            users = try await User.query().all()
        }
    }
}
```

The task is cancelled automatically when the view disappears (e.g., navigating away). If the closure throws an uncaught error, Sparrow shows an error toast automatically (see Error Handling below).

### Error Handling

When an event handler (`onClick`, `onSubmit`, `task`) throws an uncaught error, Sparrow catches it and displays an error toast with the error's localized description. The app does not crash.

```swift
// This is safe — if save() throws, user sees a toast with the error message
Button("Save", style: .primary) {
    try await save()
}

// For custom error handling, catch explicitly
Button("Save", style: .primary) {
    do {
        try await save()
    } catch {
        customErrorMessage = "Could not save: \(error.localizedDescription)"
    }
}
```

This means LLMs can write `try await` in handlers without boilerplate error handling and the app still works. The developer catches explicitly only when they want custom behavior.

### Accessibility

```swift
.accessibilityLabel("Close dialog")
.accessibilityHint("Dismisses the current dialog")
.accessibilityRole(.button)
.accessibilityHidden(true)
```

The framework generates appropriate ARIA attributes. Interactive elements without an accessibility label produce a compiler warning.

### Responsive

```swift
.frame(width: .responsive(phone: .infinity, tablet: 400, desktop: 600))
.hidden(on: .phone)             // hide on small screens
.font(.responsive(phone: .body, desktop: .title3))
```

### Animation

```swift
.transition(.opacity)                       // fade in/out
.transition(.slide(.leading))               // slide from left
.transition(.scale)                         // scale up from center
.animation(.spring(damping: 0.7))           // spring physics
.animation(.easeInOut(duration: 0.3))       // timing curve
```

Animations are CSS-based. The server sends the target state, and the client runtime applies CSS transitions/animations. No JS animation logic needed.

## Children / Slots

Primary content uses trailing closures (SwiftUI-style):

```swift
Card {
    Text("Card content")
}
```

Multiple slots use named parameters:

```swift
Card(
    header: { Text("Title").font(.headline) },
    footer: { Button("Save") { save() } }
) {
    Text("Body content")
}
```

## Conditional Rendering

```swift
// if/else
if user.isAdmin {
    AdminPanel()
}

// switch
switch loadState {
case .loading:
    Spinner()
case .loaded(let data):
    DataView(data: data)
case .error(let message):
    ErrorBanner(message: message)
}

// optional binding
if let user = currentUser {
    ProfileView(user: user)
}
```

## ForEach

```swift
ForEach(users) { user in
    UserRow(user: user)
}

// With index
ForEach(users.enumerated()) { index, user in
    UserRow(user: user, position: index)
}
```

Items must conform to `Identifiable` or provide an explicit `id` key path for efficient diffing.

## Component Parameters

Named parameters with defaults (Swift-style):

```swift
struct UserRow: View {
    var user: User
    var showAvatar: Bool = true
    var style: RowStyle = .default

    var body: some View {
        HStack(spacing: 12) {
            if showAvatar {
                Avatar(url: user.avatarURL, size: .small)
            }
            Text(user.name)
        }
    }
}

// Usage
UserRow(user: user)
UserRow(user: user, showAvatar: false, style: .compact)
```
