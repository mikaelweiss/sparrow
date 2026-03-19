/// A temporary notification. Renders to a position-fixed `<div>`.
public struct Toast: PrimitiveView, Sendable {
    public let message: String
    public let style: ToastStyle

    public init(_ message: String, style: ToastStyle = .info) {
        self.message = message
        self.style = style
    }
}

public enum ToastStyle: Sendable {
    case info, success, warning, error
}
