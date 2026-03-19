/// An internal navigation link. Renders to `<a>` with WebSocket-based navigation.
public struct NavigationLink: PrimitiveView, Sendable {
    public let label: String
    public let destination: String

    public init(_ label: String, destination: String) {
        self.label = label
        self.destination = destination
    }
}
