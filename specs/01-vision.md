# Sparrow: Vision & Philosophy

## What Sparrow Is

Sparrow is a Swift web platform. You write SwiftUI-like Swift code. It renders to server-side HTML/CSS and delivers it to the browser. The developer writes zero HTML, zero CSS, zero JavaScript.

## Who It's For

Developers who want to build a web app the way iOS developers build iOS apps — open the project, write your code, and ship. No tooling decisions, no dependency wiring, no stack assembly.

## Core Principles

1. **Zero decision fatigue.** You don't choose a router, a state manager, a CSS framework, an auth library, or a component library. Sparrow has one answer for each, and it works. It's a platform, not a collection of libraries.

2. **Beautiful by default.** The built-in design system produces professional UI out of the box. `Button("Submit", style: .primary)` looks good without design skills. No "AI slop" aesthetic.

3. **LLM-friendly from day one.** The API surface is small and consistent. One way to do things. Strong types catch mistakes. Swift's massive training corpus means LLMs already understand the syntax patterns. Less code = less bugs.

4. **One language.** Swift for everything. The UI, the logic, the data layer, the auth, the routing. No context-switching between languages.

5. **Self-sufficient.** You can build and deploy a complete app with zero third-party services. Postgres is the default. Auth is built in. You own your stack.

6. **The developer writes zero JavaScript.** Sparrow ships a small client-side JS runtime (~5-10KB) that handles WebSocket connections and DOM patching. The developer never sees or touches it.

## What Sparrow Is Not

- Not a new programming language. It's a Swift framework.
- Not a static site generator. It's a server-rendered, interactive web framework.
- Not a WASM project. Swift runs on the server, not in the browser.
- Not a wrapper around React/Svelte/Vue. The rendering model is entirely its own.

## The One-Liner

**SwiftUI for the web. Just build your app.**

## Inspirations

| Inspiration | What We Take From It |
|---|---|
| SwiftUI | Declarative component model, property wrappers, modifier chains |
| Phoenix LiveView | Server-rendered interactivity over WebSocket, no client-side framework |
| Apple HIG | Professional default design system that works for 90% of apps |
