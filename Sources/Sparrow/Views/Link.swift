/// An external hyperlink. Renders to `<a href="..." target="_blank">`.
public struct Link: PrimitiveView, Sendable {
    public let label: String
    public let url: String

    public init(_ label: String, url: String) {
        self.label = label
        self.url = url
    }
}
