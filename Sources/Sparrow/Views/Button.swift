/// A clickable button. Renders to `<button>` with event forwarding over WebSocket.
public struct Button: PrimitiveView, Sendable {
    public let label: String
    public let action: @Sendable () -> Void

    public init(_ label: String, action: @escaping @Sendable () -> Void) {
        self.label = label
        self.action = action
    }
}
