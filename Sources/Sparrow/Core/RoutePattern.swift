/// URL pattern matching with dynamic segments and wildcards.
///
/// Supports:
/// - Static paths: `/about`, `/pricing`
/// - Dynamic segments: `/users/:id`, `/posts/:slug`
/// - Catch-all wildcards: `/docs/*` (matches `/docs/a/b/c`)
public struct RoutePattern: Sendable {
    public let raw: String
    public let isNotFound: Bool
    private let segments: [Segment]

    enum Segment: Sendable {
        case literal(String)
        case param(String)
        case wildcard
    }

    public init(_ pattern: String) {
        self.raw = pattern
        self.isNotFound = false
        self.segments = Self.parse(pattern)
    }

    init(notFound: Bool) {
        self.raw = ""
        self.isNotFound = true
        self.segments = []
    }

    /// True when the pattern has no dynamic segments or wildcards.
    public var isStatic: Bool {
        segments.allSatisfy { if case .literal = $0 { return true } else { return false } }
    }

    private static func parse(_ pattern: String) -> [Segment] {
        pattern.split(separator: "/", omittingEmptySubsequences: true).map { part in
            if part == "*" { return .wildcard }
            if part.hasPrefix(":") { return .param(String(part.dropFirst())) }
            return .literal(String(part))
        }
    }

    /// Match a URL path against this pattern. Returns extracted params or nil.
    public func match(_ path: String) -> RouteParams? {
        guard !isNotFound else { return nil }

        let pathParts = path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        var params: [String: String] = [:]

        for (i, segment) in segments.enumerated() {
            switch segment {
            case .literal(let expected):
                guard i < pathParts.count, pathParts[i] == expected else { return nil }
            case .param(let name):
                guard i < pathParts.count else { return nil }
                params[name] = pathParts[i]
            case .wildcard:
                let rest = pathParts[i...].joined(separator: "/")
                return RouteParams(segments: params, wildcard: rest)
            }
        }

        guard pathParts.count == segments.count else { return nil }
        return RouteParams(segments: params)
    }
}
