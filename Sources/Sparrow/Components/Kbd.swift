/// Keyboard shortcut display matching ShadCN Kbd.
public struct Kbd: PrimitiveView, Sendable {
    public let keys: String
    public init(_ keys: String) { self.keys = keys }
}
