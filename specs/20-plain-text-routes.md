# Plain Text Routes

## Overview

Sparrow can serve plain text (`.txt`) and Markdown (`.md`) files alongside HTML pages. This is useful for LLM-consumable content (`llms.txt`), machine-readable metadata (`robots.txt`, `humans.txt`, `security.txt`), and providing text-only representations of pages for AI agents and crawlers.

## TextRoute

`TextRoute` defines a route that serves text content instead of rendered HTML. It lives alongside `Page` and `Redirect` inside `Routes`.

```swift
Routes {
    Page("/") { HomeView() }

    TextRoute("/llms.txt") {
        """
        # My App
        > A short description of what this app does.

        ## Pages
        - [Home](/): Landing page
        - [About](/about): Company info
        - [Docs](/docs): API documentation
        """
    }

    TextRoute("/robots.txt") {
        """
        User-agent: *
        Allow: /
        Sitemap: https://example.com/sitemap.xml
        """
    }
}
```

### Content-Type Inference

The content type is inferred from the path extension:

| Extension | Content-Type |
|---|---|
| `.txt` | `text/plain; charset=utf-8` |
| `.md` | `text/markdown; charset=utf-8` |
| no extension | `text/plain; charset=utf-8` |

Override explicitly when the extension doesn't match intent:

```swift
TextRoute("/special-path", contentType: .markdown) {
    "# This is markdown served at a path with no .md extension"
}
```

### Dynamic Content

The closure is `async throws`, so you can query the database or do any server-side work:

```swift
TextRoute("/llms.txt") {
    let pages = try await SitePage.query().all()

    return """
    # My App
    > A tool for managing widgets.

    ## Pages
    \(pages.map { "- [\($0.title)](\($0.path)): \($0.description)" }.joined(separator: "\n"))
    """
}
```

### Route Parameters

Dynamic segments work the same as `Page`:

```swift
TextRoute("/posts/:slug.md") { params in
    let post = try await Post.query().where(\.slug, params.slug).first()
    return """
    # \(post.title)

    \(post.markdownContent)
    """
}
```

## Content-Type Enum

```swift
enum TextContentType {
    case plain      // text/plain; charset=utf-8
    case markdown   // text/markdown; charset=utf-8
}
```

## Middleware & Groups

`TextRoute` works with route groups and middleware, same as `Page`:

```swift
RouteGroup {
    TextRoute("/internal/docs.md") {
        "# Internal Documentation\n..."
    }
}
.authenticated()
```

## No WebSocket, No JS Runtime

Text routes are HTTP-only. They return the text body with the appropriate `Content-Type` header. No `<html>` wrapper, no Sparrow client runtime, no WebSocket connection. Just the raw text content in the response body.

## SEO & Caching

Text routes support caching headers:

```swift
TextRoute("/llms.txt") {
    "..."
}
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

- **`TextRoute`** — you write the text content yourself. Full control. Use for `llms.txt`, `robots.txt`, hand-crafted docs, API descriptions.
- **`.textRepresentation()` / `.markdownRepresentation()`** — auto-derived from an existing page's View tree. Use when you want a text mirror of an HTML page without maintaining two copies of the content.
