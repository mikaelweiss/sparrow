/// A single-line text input. Renders to `<input type="text">`.
public struct TextField: PrimitiveView, Sendable {
    public let placeholder: String
    public let text: String

    public init(_ placeholder: String, text: String = "") {
        self.placeholder = placeholder
        self.text = text
    }
}
