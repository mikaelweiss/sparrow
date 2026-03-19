# Rendering Pipeline

## Overview

The rendering pipeline transforms Swift View structs into HTML strings. It runs on the server for every page load and on every state change. The pipeline must be fast (sub-millisecond for small components), deterministic (same input → same output), and produce semantic, accessible HTML.

## Pipeline Stages

```
Swift View Tree → HTML IR → HTML String → (Diff) → Patches
```

### Stage 1: View Resolution

The framework walks the View tree, resolving `body` properties recursively until it reaches primitive views (Text, VStack, Button, etc.).

```swift
// Input
ProfileCard(user: user)

// Resolves to:
VStack(spacing: 12) {
    Avatar(url: user.avatarURL, size: .large)
    Text(user.name)
        .font(.title)
        .foreground(.primary)
}
.padding(16)
.background(.surface)
.cornerRadius(.md)
```

Each resolved primitive is assigned a stable ID based on its position in the tree (and any explicit `id` modifiers). These IDs are used for diffing and event routing.

### Stage 2: HTML IR Generation

Each primitive view generates an HTML Intermediate Representation — a lightweight node tree that maps views to HTML elements and CSS classes.

```
HTMLNode(
    tag: "div",
    id: "v_0_0",
    classes: ["flex", "flex-col", "gap-3", "p-4", "bg-surface", "rounded-md"],
    children: [
        HTMLNode(
            tag: "img",
            id: "v_0_0_0",
            classes: ["avatar", "avatar-lg"],
            attributes: ["src": user.avatarURL, "alt": user.name]
        ),
        HTMLNode(
            tag: "h2",
            id: "v_0_0_1",
            classes: ["font-title", "fg-primary"],
            text: user.name
        )
    ]
)
```

### Stage 3: HTML String Serialization

The IR is serialized to an HTML string. For the initial page load, this is wrapped in a full HTML document.

### Stage 4: Diffing (WebSocket updates only)

On state changes, the renderer produces new HTML for the affected subtree. The differ compares old vs. new HTML and produces minimal patches.

## Initial Page Load (SSR)

On `GET /profile/123`, the server produces a complete HTML document:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Profile — MyApp</title>
    <meta name="description" content="...">
    <meta property="og:title" content="Profile">
    <link rel="stylesheet" href="/sparrow.css">
</head>
<body>
    <div id="sparrow-root">
        <div id="v_0" class="flex flex-col gap-3 p-4 bg-surface rounded-md">
            <img id="v_0_0" class="avatar avatar-lg" src="..." alt="Mikael">
            <h2 id="v_0_1" class="font-title fg-primary">Mikael</h2>
        </div>
    </div>
    <script src="/sparrow-runtime.js"></script>
    <script>Sparrow.connect("ws://...", "session_token_here");</script>
</body>
</html>
```

The page is immediately renderable. No JavaScript needs to execute before the user sees content. The runtime JS boots after the page is visible and establishes the WebSocket for interactivity.

## View-to-HTML Mapping

### Layout Views

| Swift | HTML | CSS Classes |
|---|---|---|
| `VStack(spacing: 12)` | `<div>` | `flex flex-col gap-3` |
| `HStack(spacing: 8)` | `<div>` | `flex flex-row gap-2` |
| `ZStack` | `<div>` | `relative` (children get `absolute`) |
| `Spacer()` | `<div>` | `flex-grow` |
| `Divider()` | `<hr>` | `divider` |
| `ScrollView(.vertical)` | `<div>` | `overflow-y-auto` |
| `Grid(columns: 3)` | `<div>` | `grid grid-cols-3` |

### Semantic HTML

The renderer produces semantic HTML elements, not just divs:

| Swift | HTML |
|---|---|
| `Text("...").font(.title)` | `<h2>` |
| `Text("...").font(.largeTitle)` | `<h1>` |
| `Text("...")` (body context) | `<p>` |
| `Button("...")` | `<button>` |
| `NavigationLink("...")` | `<a href="...">` |
| `TextField("...")` | `<input type="text">` |
| `Form { ... }` | `<form>` |
| `List { ... }` | `<ul>` |
| `Section(header:)` | `<section>` with `<h3>` |
| `Image(...)` | `<img>` |
| `Modal(...)` | `<dialog>` |

This is critical for SEO, accessibility, and browser features (password managers, form autofill, screen readers, keyboard navigation).

## Modifier-to-CSS Mapping

Modifiers accumulate CSS classes. Multiple modifiers on the same view combine their classes:

```swift
Text("Hello")
    .font(.title)
    .foreground(.primary)
    .padding(16)
    .background(.surface)
    .cornerRadius(.md)

// → <h2 class="font-title fg-primary p-4 bg-surface rounded-md">Hello</h2>
```

### Spacing Modifiers

| Swift | CSS Class | CSS |
|---|---|---|
| `.padding(4)` | `p-1` | `padding: 4px` |
| `.padding(8)` | `p-2` | `padding: 8px` |
| `.padding(16)` | `p-4` | `padding: 16px` |
| `.padding(.horizontal, 16)` | `px-4` | `padding-left: 16px; padding-right: 16px` |
| `.padding(.top, 8)` | `pt-2` | `padding-top: 8px` |
| `.margin(16)` | `m-4` | `margin: 16px` |

### Frame Modifiers

| Swift | CSS Class / Inline |
|---|---|
| `.frame(width: 200)` | `width: 200px` |
| `.frame(maxWidth: .infinity)` | `width: 100%` |
| `.frame(minHeight: 44)` | `min-height: 44px` |

Frame modifiers use inline styles because they're typically unique per-component. Design-system values use classes.

## Diffing Algorithm

When state changes, the renderer:

1. Re-renders only the affected component subtree (not the whole page)
2. Produces new HTML for that subtree
3. Compares old HTML vs. new HTML at the node level

The diff produces a list of patches:

```json
[
    {"op": "text", "target": "#v_0_1", "value": "Count: 2"},
    {"op": "replace", "target": "#v_0_2", "html": "<div class='badge badge-success'>Active</div>"},
    {"op": "remove", "target": "#v_0_3"},
    {"op": "append", "target": "#v_0", "html": "<p class='font-body'>New item</p>"},
    {"op": "attr", "target": "#v_0_4", "attr": "class", "value": "btn btn-primary disabled"}
]
```

Patch types:
- `text` — update text content of a node
- `replace` — replace a node's entire HTML
- `remove` — remove a node
- `append` — add a new child node
- `prepend` — add a new child at the beginning
- `attr` — update an attribute (class, disabled, etc.)
- `reorder` — reorder children (for list diffing with keys)

## Event Handling

Interactive elements get `data-sparrow-event` attributes:

```html
<button id="v_0_2" class="btn btn-primary" data-sparrow-event="click">
    Increment
</button>

<input id="v_0_3" type="text" data-sparrow-event="input" data-sparrow-debounce="300">
```

The client runtime captures these events and sends them over WebSocket:

```json
{"event": "click", "target": "v_0_2"}
{"event": "input", "target": "v_0_3", "value": "search text"}
```

### Input Debouncing

Text inputs are debounced by default (300ms) to avoid sending every keystroke. This is configurable:

```swift
TextField("Search", text: $searchText)
    .debounce(500)        // 500ms debounce
    .debounce(0)          // no debounce (send every keystroke)
```

### Form Submission

Forms collect all input values and send them in one event:

```json
{"event": "submit", "target": "v_form_0", "values": {"email": "...", "password": "..."}}
```

## CSS Generation

At build time, Sparrow generates `sparrow.css`:

1. **Reset/normalize** — consistent cross-browser baseline
2. **Design tokens** — CSS custom properties from the theme
3. **Utility classes** — all modifier-mapped classes (tree-shaken: only used classes are included)
4. **Component styles** — styles for built-in components (Button variants, Card, Modal, etc.)
5. **Animation keyframes** — for built-in transitions

The CSS is generated once, not per-request. It's served as a static file and cached by the browser.

## Performance Considerations

- **Rendering is a pure function**: View tree + state → HTML string. No side effects, no shared mutable state. Safe to call from any context.
- **Partial re-rendering**: Only the changed subtree re-renders, not the whole page.
- **String building**: HTML is built using contiguous byte buffers, not string concatenation, for minimal allocations.
- **Diffing scope**: The differ only compares the re-rendered subtree, not the whole document.
- **Static subtrees**: Components with no `@State` or `@Binding` are detected at build time and cached — they render once and are reused.
