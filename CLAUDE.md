# Sparrow

A batteries-included Swift web framework. SwiftUI-like code on the server → HTML/CSS in the browser. Zero JS written by the developer.

## Architecture

- **Server-rendered** — Swift runs on the server (Hummingbird, hidden from developer), generates HTML, serves to browser
- **LiveView model** — persistent WebSocket per user. State lives on server in Swift Actors. State change → re-render → diff → patch DOM
- **Client JS runtime** — ~5-10KB JS handles WebSocket, DOM patching, event forwarding. Developer never touches it
- **SSR on first load** — full HTML page for SEO. WebSocket takes over for interactivity

## Key Decisions

- Swift, not a new language. Hummingbird under the hood, not Vapor
- SwiftUI-like DSL generates semantic HTML + utility CSS classes from design tokens
- @State/@Binding/@Environment/@Store for state (SwiftUI model)
- CSS custom properties for theming, generated stylesheet, developer writes zero CSS
- @Model macro + Postgres for data, type-safe query DSL
- Built-in email/password auth, session-based
- `sparrow new` → 2 files (Sparrow.toml + App.swift). `sparrow run` starts everything

## Specs

Detailed specs in `specs/`. Read the relevant spec before implementing a feature:

| Feature | Spec |
|---|---|
| Component model, views, modifiers | `specs/03-component-dsl.md` |
| Colors, typography, spacing, theming | `specs/04-design-system.md` |
| @State, @Binding, @Environment, reactivity | `specs/05-state-management.md` |
| Routes, layouts, navigation, SEO | `specs/06-routing.md` |
| @Model, queries, migrations, Postgres | `specs/07-data-layer.md` |
| Auth, sessions, guards | `specs/08-auth.md` |
| CLI commands, JSON mode | `specs/09-cli.md` |
| View → HTML, diffing, CSS generation | `specs/10-rendering-pipeline.md` |
| WebSocket protocol, DOM patching, events | `specs/11-client-runtime.md` |
| File watcher, rebuild, browser refresh | `specs/12-hot-reload.md` |
| Sparrow.toml, file layout, discovery | `specs/13-project-structure.md` |
| Testing views, state, data, auth | `specs/14-testing.md` |
| Build output, Docker, deploy | `specs/15-deployment.md` |
| Semantic HTML, ARIA, focus, keyboard | `specs/16-accessibility.md` |
| Transitions, animation curves, CSS-based | `specs/17-animations.md` |
| Forms, validators, file upload | `specs/18-forms-validation.md` |
| Vision, philosophy, inspirations | `specs/01-vision.md` |
| Full architecture diagram, request lifecycle | `specs/02-architecture.md` |

## Build Order

Phase 1: Core rendering (View protocol, primitives, modifiers, HTML renderer, CSS generator)
Phase 2: Server + interactivity (Hummingbird, SSR, WebSocket, session actors, @State, client JS)
Phase 3: Routing + navigation
Phase 4: Data + auth
Phase 5: Full component library, design system, forms, animations, testing, CLI
Phase 6: Docker, deployment, docs, ship
