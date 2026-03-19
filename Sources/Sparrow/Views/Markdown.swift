/// Renders a markdown string to HTML.
public struct Markdown: PrimitiveView, Sendable {
    public let content: String

    public init(_ content: String) {
        self.content = content
    }
}
