# Plain Text Routes

## Overview

Sparrow can serve plain text (`.txt`) and Markdown (`.md`) files alongside HTML pages. This is useful for LLM-consumable content (`llms.txt`), machine-readable metadata (`robots.txt`, `humans.txt`, `security.txt`), and providing text-only representations of pages for AI agents and crawlers.

## FileRoute

`FileRoute` serves a file from disk at a given URL path. It lives alongside `Page` and `Redirect` inside `Routes`. The file content is read from disk — no string literals, no closures. Generate files at build time if they need dynamic data.

```swift
Routes {
    Page("/") { HomeView() }

    FileRoute("/llms.txt", file: "llms.txt")
    FileRoute("/robots.txt", file: "robots.txt")
}
```

The `file` parameter is a path relative to the project root (where `Sparrow.toml` lives).

### Content-Type Inference

The content type is inferred from the URL path extension:

| Extension | Content-Type |
|---|---|
| `.txt` | `text/plain; charset=utf-8` |
| `.md` | `text/markdown; charset=utf-8` |
| no extension | `text/plain; charset=utf-8` |

Override explicitly when the extension doesn't match intent:

```swift
FileRoute("/special-path", file: "docs.md", contentType: .markdown)
```

## Content-Type Enum

```swift
enum TextContentType {
    case plain      // text/plain; charset=utf-8
    case markdown   // text/markdown; charset=utf-8
}
```

## Middleware & Groups

`FileRoute` works with route groups and middleware, same as `Page`:

```swift
RouteGroup {
    FileRoute("/internal/docs.md", file: "internal-docs.md")
}
.authenticated()
```

## No WebSocket, No JS Runtime

File routes are HTTP-only. They return the file contents with the appropriate `Content-Type` header. No `<html>` wrapper, no Sparrow client runtime, no WebSocket connection. Just the raw file content in the response body.

## Caching

File routes support caching headers:

```swift
FileRoute("/llms.txt", file: "llms.txt")
    .cacheControl(.public, maxAge: 3600)  // Cache for 1 hour
```

No `<meta>` tags or Open Graph — those are HTML concepts. Search engines that understand `llms.txt` and `robots.txt` already know how to find them.

## Page Text Representation

A `Page` can optionally expose a text or markdown version of itself at a separate path. This auto-extracts the text content from the View tree — stripping HTML tags, flattening layout containers, and preserving the text hierarchy.

```swift
Page("/about") { AboutView() }
    .textRepresentation(at: "/about.txt")
    .markdownRepresentation(at: "/about.md")
```

### Extraction Rules

The renderer walks the resolved View tree and extracts text:

| View | Text Output |
|---|---|
| `Text("Hello")` with `.font(.largeTitle)` | `# Hello` |
| `Text("Hello")` with `.font(.title)` | `## Hello` |
| `Text("Hello")` with `.font(.title2)` | `### Hello` |
| `Text("Hello")` (body) | `Hello` (paragraph) |
| `Markdown("...")` | Pass through as-is |
| `Image(url:)` | `![alt](url)` |
| `NavigationLink("X", destination: "/y")` | `[X](/y)` |
| `Link("X", url: "...")` | `[X](url)` |
| `List { ... }` | `- item` per child |
| `Divider()` | `---` |
| `Button(...)` | *(omitted)* |
| `TextField(...)` | *(omitted)* |
| Layout views (`VStack`, `HStack`, etc.) | Recurse into children, separate with newlines |

Interactive elements (buttons, inputs, toggles) are omitted since they have no meaning in a text context. Layout containers are transparent — the extractor recurses through them.

### When to Use What

- **`FileRoute`** — serves a file from disk. Use for `llms.txt`, `robots.txt`, pre-generated docs. Generate the file at build time if it needs dynamic data.
- **`.textRepresentation()` / `.markdownRepresentation()`** — auto-derived from an existing page's View tree. Use when you want a text mirror of an HTML page without maintaining two copies of the content.
