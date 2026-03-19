/// A single-line text input. Renders to `<input type="text">`.
/// Accepts a `Binding<String>` to round-trip values from the browser.
public struct TextField: PrimitiveView, Sendable {
    public let placeholder: String
    public let text: Binding<String>

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }
}
