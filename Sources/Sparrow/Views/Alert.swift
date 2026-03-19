/// An alert dialog. Renders to `<div role="alert">`.
public struct Alert: PrimitiveView, Sendable {
    public let title: String
    public let message: String

    public init(title: String, message: String = "") {
        self.title = title
        self.message = message
    }
}
