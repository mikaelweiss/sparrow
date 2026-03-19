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

/// Convenience for declaring a page route inline.
public func Page<Content: View & Sendable>(
    _ path: String,
    title: String? = nil,
    @ViewBuilder content: () -> Content
) -> Route {
    Route(path: path, title: title, view: content())
}
