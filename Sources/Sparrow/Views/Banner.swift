/// A persistent informational banner. Composes a styled Text with role="status".
public struct Banner: View, Sendable {
    public let message: String
    public let style: BannerStyle

    public init(_ message: String, style: BannerStyle = .info) {
        self.message = message
        self.style = style
    }

    public var body: some View {
        Text(message)
            .modifier(BannerStyleModifier(style: style))
    }

    public enum BannerStyle: Sendable {
        case info
        case success
        case warning
        case error
    }
}

struct BannerStyleModifier: ViewModifier, Sendable {
    let style: Banner.BannerStyle
    var cssClasses: [String] {
        let variant: String
        switch style {
        case .info: variant = "info"
        case .success: variant = "success"
        case .warning: variant = "warning"
        case .error: variant = "error"
        }
        return ["banner", "banner-\(variant)"]
    }
    var inlineStyles: [String: String] { [:] }
    var createsLayer: Bool { true }
}
