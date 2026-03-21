# Routing

## Overview

Routing in Sparrow is declarative. You define pages in your `App` struct. The router matches URLs to views. Every page is server-rendered on first load (SEO), then subsequent navigation happens over WebSocket without full page reloads.

## Basic Routing

```swift
@main
struct MyApp: App {
    var body: some Scene {
        Routes {
            Page("/") { HomeView() }
            Page("/about") { AboutView() }
            Page("/pricing") { PricingView() }
        }
    }
}
```

## Dynamic Segments

```swift
Routes {
    Page("/users/:id") { params in
        UserProfileView(userId: params.id)
    }
    Page("/posts/:slug") { params in
        PostView(slug: params.slug)
    }
}
```

`params` is a type-safe struct. `:id` and `:slug` are `String` by default. Type conversion is explicit:

```swift
Page("/users/:id") { params in
    let userId = UUID(params.id)
    UserProfileView(userId: userId)
}
```

## Route Groups & Layouts

Group routes that share a layout:

```swift
Routes {
    // Public pages — no auth, marketing layout
    RouteGroup(layout: MarketingLayout.self) {
        Page("/") { HomeView() }
        Page("/about") { AboutView() }
        Page("/pricing") { PricingView() }
    }

    // Dashboard pages — auth required, dashboard layout
    RouteGroup(layout: DashboardLayout.self) {
        Page("/dashboard") { DashboardView() }
        Page("/settings") { SettingsView() }
        Page("/profile") { ProfileView() }
    }
    .authenticated()  // all pages in this group require auth
}
```

### Layouts

A layout is a view that wraps page content:

```swift
struct DashboardLayout: Layout {
    var body: some View {
        VStack {
            NavBar()
            HStack {
                Sidebar()
                Content()    // <-- page content renders here
            }
        }
    }
}
```

`Content()` is a placeholder that Sparrow replaces with the matched page's content. When navigating between pages in the same layout group, only the `Content()` portion re-renders — the layout stays.

## Navigation

### NavigationLink

Client-side navigation without full page reload:

```swift
NavigationLink("View Profile", destination: "/users/\(user.id)")
```

When clicked:
1. Client JS sends navigation event over WebSocket
2. Server renders the destination page
3. Server sends HTML diff
4. Client patches DOM and updates browser URL via `pushState`

### Programmatic Navigation

```swift
struct CreatePostView: View {
    @Environment(\.navigator) var navigator

    var body: some View {
        Form {
            // ...
            Button("Create") {
                let post = try await createPost()
                navigator.push("/posts/\(post.slug)")
            }
        }
    }
}
```

### External Links

For links that leave your site:

```swift
Link("GitHub", url: "https://github.com")           // opens in same tab
Link("Docs", url: "https://docs.example.com")
    .opensInNewTab()                                  // target="_blank"
```

## Query Parameters

```swift
Page("/search") { params in
    SearchView(query: params.query["q"], page: params.query["page"])
}
```

`params.query` is a `[String: String?]` dictionary.

## 404 / Not Found

```swift
Routes {
    Page("/") { HomeView() }
    // ... other routes

    Page(.notFound) {
        NotFoundView()
    }
}
```

If no route matches, the `notFound` page renders. If not defined, Sparrow shows a default 404 page.

## Catch-All Routes

Match an entire subtree of paths with a wildcard:

```swift
Routes {
    Page("/docs/*") { params in
        DocsView(path: params.wildcard ?? "")
    }
}
```

`/docs/*` matches `/docs/getting-started`, `/docs/api/auth`, etc. The matched portion is available as `params.wildcard`.

## Redirects

```swift
Routes {
    Redirect("/old-path", to: "/new-path")
    Redirect("/legacy/:id", to: "/modern/:id")   // preserves params
}
```

## Fragment Links (Anchors)

Fragment links scroll to a specific section of the page. Use `.id()` to set an anchor target:

```swift
struct DocsView: View {
    var body: some View {
        VStack {
            // Table of contents
            NavigationLink("Installation", destination: "#installation")
            NavigationLink("Usage", destination: "#usage")

            // Sections
            Text("Installation").font(.title).id("installation")
            Text("Run: sparrow new MyApp")

            Text("Usage").font(.title).id("usage")
            Text("Run: sparrow run")
        }
    }
}
```

When clicked:
1. Same-page fragments (`#section`) scroll without a server round-trip
2. Cross-page fragments (`/docs#section`) navigate then scroll after load
3. Pasting a URL with a fragment (e.g. `yoursite.com/docs#usage`) loads the page and scrolls natively

## SEO

Because every page is server-rendered on the initial HTTP request, search engines see complete HTML content. Each page can define metadata:

```swift
struct BlogPostView: View {
    var post: Post

    var body: some View {
        VStack {
            Text(post.title).font(.largeTitle)
            Markdown(post.content)
        }
        .pageTitle(post.title)
        .pageDescription(post.excerpt)
        .pageImage(post.coverImageURL)     // Open Graph image
        .canonicalURL("/posts/\(post.slug)")
    }
}
```

This generates appropriate `<title>`, `<meta>` description, Open Graph tags, and canonical URL in the `<head>`.

## Middleware

Route-level middleware for auth, logging, rate limiting, etc.:

```swift
RouteGroup {
    Page("/admin") { AdminView() }
}
.authenticated()                    // built-in auth middleware
.requireRole(.admin)                // built-in role check
```

Custom middleware:

```swift
struct LoggingMiddleware: Middleware {
    func handle(request: Request, next: Next) async throws -> Response {
        print("Request: \(request.url)")
        return try await next.handle(request)
    }
}

RouteGroup {
    Page("/api-heavy") { HeavyView() }
}
.middleware(LoggingMiddleware())
```
