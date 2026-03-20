/// An internal navigation link. Renders to `<a>` with WebSocket-based navigation.
public struct NavigationLink: PrimitiveView, Sendable {
    public let label: String
    public let destination: String
    public let current: Bool

    public init(_ label: String, destination: String, current: Bool = false) {
        self.label = label
        self.destination = destination
        self.current = current
    }
}
