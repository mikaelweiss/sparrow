/// A multi-line text input. Renders to `<textarea>`.
public struct TextEditor: PrimitiveView, Sendable {
    public let text: String

    public init(text: String = "") {
        self.text = text
    }
}
