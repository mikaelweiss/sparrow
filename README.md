# Sparrow

A batteries-included Swift web framework. SwiftUI-like code on the server, HTML/CSS in the browser. Zero JavaScript written by the developer.

```swift
struct HomePage: View {
    var body: some View {
        VStack {
            Text("Hello, Sparrow")
                .font(.title)
            Text("Ship in minutes.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
```

## Why Sparrow

- **Zero decision fatigue.** Router, state management, design system, auth, data layer — all built in. One answer for each, and it works.
- **Beautiful by default.** The built-in design system produces professional UI out of the box. No design skills required.
- **One language.** Swift for everything. UI, logic, data, auth, routing. No context-switching.
- **No JavaScript.** A small client runtime (~5-10KB) handles WebSocket and DOM patching. You never touch it.
- **LLM-friendly.** Small, consistent API surface. Strong types. One way to do things.

## How It Works

Sparrow is server-rendered with a LiveView model:

1. Swift runs on the server (powered by [Hummingbird](https://github.com/hummingbird-project/hummingbird))
2. First request gets full SSR HTML (SEO-friendly)
3. WebSocket takes over for interactivity
4. State changes trigger re-render → diff → DOM patch

The developer writes SwiftUI-like Swift. Sparrow generates semantic HTML and utility CSS from design tokens.

## Getting Started

**Requirements:** Swift 6.2+, macOS 15+

```bash
# Install the CLI
swift package experimental-install
export PATH="$HOME/.swiftpm/bin:$PATH"

# Create a new project
sparrow new

# Run the dev server
cd my-project
sparrow run
```

## Documentation

Detailed specs live in [`specs/`](specs/):

| Topic | Spec |
|---|---|
| Vision & philosophy | [`01-vision.md`](specs/01-vision.md) |
| Architecture | [`02-architecture.md`](specs/02-architecture.md) |
| Component DSL | [`03-component-dsl.md`](specs/03-component-dsl.md) |
| Design system | [`04-design-system.md`](specs/04-design-system.md) |
| State management | [`05-state-management.md`](specs/05-state-management.md) |
| Routing | [`06-routing.md`](specs/06-routing.md) |
| Data layer | [`07-data-layer.md`](specs/07-data-layer.md) |
| Auth | [`08-auth.md`](specs/08-auth.md) |
| CLI | [`09-cli.md`](specs/09-cli.md) |

See [`DEVELOPMENT.md`](DEVELOPMENT.md) for contributor setup and dev workflows.

## License

Apache 2.0 — see [LICENSE](LICENSE).
