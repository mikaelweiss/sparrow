/// A multi-line text input. Renders to `<textarea>`.
/// Accepts a `Binding<String>` to round-trip values from the browser.
public struct TextEditor: PrimitiveView, Sendable {
    public let text: Binding<String>

    public init(text: Binding<String>) {
        self.text = text
    }
}
