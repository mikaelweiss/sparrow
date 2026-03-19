/// An icon-text pair. Renders to a span with an icon and text.
public struct Label: PrimitiveView, Sendable {
    public let title: String
    public let icon: String

    public init(_ title: String, icon: String) {
        self.title = title
        self.icon = icon
    }
}
