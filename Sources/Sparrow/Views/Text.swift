/// Displays a string of text. Renders to <p>, <span>, or <h1>-<h6> depending on font modifier.
public struct Text: PrimitiveView, Sendable {
    public let content: String

    public init(_ content: String) {
        self.content = content
    }
}
