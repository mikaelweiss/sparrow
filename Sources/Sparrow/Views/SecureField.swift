/// A password input. Renders to `<input type="password">`.
public struct SecureField: PrimitiveView, Sendable {
    public let placeholder: String
    public let text: String

    public init(_ placeholder: String, text: String = "") {
        self.placeholder = placeholder
        self.text = text
    }
}
