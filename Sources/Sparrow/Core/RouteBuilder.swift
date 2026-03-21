/// Result builder for declaring routes.
@resultBuilder
public struct RouteBuilder {
    public static func buildExpression(_ route: Route) -> [Route] {
        [route]
    }

    public static func buildExpression(_ routes: [Route]) -> [Route] {
        routes
    }

    public static func buildBlock(_ routes: [Route]...) -> [Route] {
        routes.flatMap { $0 }
    }

    public static func buildArray(_ components: [[Route]]) -> [Route] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [Route]?) -> [Route] {
        component ?? []
    }

    public static func buildEither(first component: [Route]) -> [Route] {
        component
    }

    public static func buildEither(second component: [Route]) -> [Route] {
        component
    }
}

// MARK: - Page (static)

/// Declare a page route with static content.
public func Page<Content: View & Sendable>(
    _ path: String,
    title: String? = nil,
    @ViewBuilder content: () -> Content
) -> Route {
    Route(path: path, title: title, view: content())
}

// MARK: - Page (parameterized)

/// Declare a page route with dynamic segments.
/// The closure receives extracted `RouteParams`.
///
/// ```swift
/// Page("/users/:id") { params in
///     UserProfileView(userId: params.id)
/// }
/// ```
public func Page<Content: View & Sendable>(
    _ path: String,
    title: String? = nil,
    @ViewBuilder content: @escaping @Sendable (RouteParams) -> Content
) -> Route {
    Route(path: path, title: title, viewBuilder: content)
}

// MARK: - Page (not found)

/// Declare a custom 404 page.
///
/// ```swift
/// Page(.notFound) { NotFoundView() }
/// ```
public func Page<Content: View & Sendable>(
    _ special: RouteSpecial,
    title: String? = nil,
    @ViewBuilder content: () -> Content
) -> Route {
    switch special {
    case .notFound:
        return Route(notFound: content())
    }
}

/// Special route types.
public enum RouteSpecial: Sendable {
    case notFound
}

// MARK: - FileRoute

/// Declare a file route. Content type is inferred from the path extension:
/// `.md` → markdown, everything else → plain text.
public func FileRoute(
    _ path: String,
    file: String,
    contentType: RouteContentType? = nil
) -> Route {
    let resolved = contentType ?? (path.hasSuffix(".md") ? .markdown : .plain)
    return Route(path: path, contentType: resolved, file: file)
}

// MARK: - RouteGroup

/// Group routes that share a layout. When navigating between pages in the
/// same layout group, only the `Content()` area re-renders.
///
/// ```swift
/// RouteGroup(layout: DashboardLayout.self) {
///     Page("/dashboard") { DashboardView() }
///     Page("/settings") { SettingsView() }
/// }
/// ```
public func RouteGroup<L: Layout>(
    layout: L.Type,
    @RouteBuilder routes: () -> [Route]
) -> [Route] {
    let layoutId = String(describing: L.self)
    return routes().map { route in
        Route(
            path: route.path,
            title: route.title,
            contentType: route.contentType,
            layoutId: layoutId,
            redirect: route.redirect,
            renderBody: route._renderBody,
            renderLayout: { renderer, contentHTML in
                renderer.renderState.contentSlot = contentHTML
                return renderer.render(L.init())
            }
        )
    }
}
