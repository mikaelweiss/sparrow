/// A status badge. Renders to a styled `<span>`.
public struct Badge: PrimitiveView, Sendable {
    public let text: String
    public let style: BadgeStyle

    public init(_ text: String, style: BadgeStyle = .default) {
        self.text = text
        self.style = style
    }
}

public enum BadgeStyle: Sendable {
    case `default`, success, warning, error, info
}
