/// Result builder for declaring routes.
@resultBuilder
public struct RouteBuilder {
    public static func buildBlock(_ routes: Route...) -> [Route] {
        routes
    }
}

/// Convenience for declaring a page route inline.
public func Page<Content: View & Sendable>(
    _ path: String,
    title: String? = nil,
    @ViewBuilder content: () -> Content
) -> Route {
    Route(path: path, title: title, view: content())
}
