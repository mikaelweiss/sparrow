/// A persistent informational banner. Renders to a full-width `<div>` with a dismiss option.
public struct Banner: PrimitiveView, Sendable {
    public let message: String
    public let style: BannerStyle

    public init(_ message: String, style: BannerStyle = .info) {
        self.message = message
        self.style = style
    }

    public enum BannerStyle: Sendable {
        case info
        case success
        case warning
        case error
    }
}
