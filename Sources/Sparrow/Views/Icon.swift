/// A system icon from the built-in icon set. Renders to `<svg>`.
public struct Icon: PrimitiveView, Sendable {
    public let systemName: String

    public init(_ systemName: String) {
        self.systemName = systemName
    }
}
