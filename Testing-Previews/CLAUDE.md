# Testing-Previews

Sparrow web application — Swift on the server, HTML/CSS in the browser.

## Stack

- **Framework:** Sparrow (SwiftUI-like DSL → semantic HTML + CSS)
- **Language:** Swift 6.2+
- **Pattern:** Server-rendered with LiveView interactivity (WebSocket)

## Project Structure

- `Sources/App.swift` — Entry point with routes and views
- `Package.swift` — Swift package configuration

## Sparrow Basics

Views use SwiftUI syntax that renders to HTML:

```swift
struct MyView: View {
    @State var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("Count: \(count)")
            Button("+") { count += 1 }
        }
        .padding(16)
    }
}
```

Routes map URLs to views:

```swift
Page("/") { HomeView() }
Page("/about") { AboutView() }
```

## Conventions

- Views are `View`-conforming structs with a `body` property
- `@State` for local state, `$binding` for two-way binding
- Routes: `Page("/path") { ViewName() }` in the App's `routes` property
- Modifiers chain: `.font(.title)`, `.padding(16)`, `.foregroundStyle(.blue)`
- No JavaScript — all interactivity is server-side

## Commands

- `sparrow serve` — Dev server with hot reload
- `sparrow build` — Production build

## Docs

Full framework docs: https://sparrowframework.dev/llms.txt