/// Semantic colors from the design system.
public enum SemanticColor: Sendable {
    case primary
    case secondary
    case accent
    case background
    case surface
    case surfaceSecondary
    case text
    case textSecondary
    case textTertiary
    case error
    case success
    case warning
    case info
    case hex(String)

    var cssValue: String {
        switch self {
        case .primary: "primary"
        case .secondary: "secondary"
        case .accent: "accent"
        case .background: "background"
        case .surface: "surface"
        case .surfaceSecondary: "surfaceSecondary"
        case .text: "text"
        case .textSecondary: "textSecondary"
        case .textTertiary: "textTertiary"
        case .error: "error"
        case .success: "success"
        case .warning: "warning"
        case .info: "info"
        case .hex(let value): "[\(value)]"
        }
    }
}

public struct ForegroundModifier: ViewModifier, Sendable {
    public let color: SemanticColor
    public var cssClasses: [String] { ["fg-\(color.cssValue)"] }
    public var inlineStyles: [String: String] { [:] }
}

public struct BackgroundModifier: ViewModifier, Sendable {
    public let color: SemanticColor
    public var cssClasses: [String] { ["bg-\(color.cssValue)"] }
    public var inlineStyles: [String: String] { [:] }
}

extension View {
    public func foreground(_ color: SemanticColor) -> ModifiedView<Self, ForegroundModifier> {
        modifier(ForegroundModifier(color: color))
    }

    public func background(_ color: SemanticColor) -> ModifiedView<Self, BackgroundModifier> {
        modifier(BackgroundModifier(color: color))
    }
}
