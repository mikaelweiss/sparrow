/// Semantic colors from the design system.
public enum SemanticColor: Sendable {
    // MARK: Semantic (role-based)
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

    // MARK: Named palette (appearance-based)
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case blue
    case indigo
    case purple
    case pink
    case brown
    case gray
    case white
    case black
    case clear

    // MARK: Escape hatch
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
        case .red: "red"
        case .orange: "orange"
        case .yellow: "yellow"
        case .green: "green"
        case .mint: "mint"
        case .teal: "teal"
        case .cyan: "cyan"
        case .blue: "blue"
        case .indigo: "indigo"
        case .purple: "purple"
        case .pink: "pink"
        case .brown: "brown"
        case .gray: "gray"
        case .white: "white"
        case .black: "black"
        case .clear: "clear"
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
