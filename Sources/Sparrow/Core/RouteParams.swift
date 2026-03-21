/// Type-safe route parameters extracted from a URL match.
///
/// Dynamic segments are accessible via dynamic member lookup:
/// ```swift
/// Page("/users/:id") { params in
///     UserView(userId: params.id)
/// }
/// ```
@dynamicMemberLookup
public struct RouteParams: Sendable {
    public let segments: [String: String]
    public let query: [String: String]
    public let wildcard: String?

    public static let empty = RouteParams()

    public init(segments: [String: String] = [:], query: [String: String] = [:], wildcard: String? = nil) {
        self.segments = segments
        self.query = query
        self.wildcard = wildcard
    }

    public subscript(dynamicMember member: String) -> String {
        segments[member] ?? ""
    }
}
