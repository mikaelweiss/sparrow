/// A status badge. Composes a styled Text.
///
/// Variants match shadcn Badge: default, secondary, destructive, outline,
/// plus semantic convenience variants (success, warning, info).
public struct Badge: View, Sendable {
    public let text: String
    public let variant: BadgeVariant

    public init(_ text: String, variant: BadgeVariant = .default) {
        self.text = text
        self.variant = variant
    }

    public var body: some View {
        Text(text)
            .modifier(BadgeStyleModifier(variant: variant))
    }
}

public enum BadgeVariant: Sendable {
    case `default`
    case secondary
    case destructive
    case outline
    // Semantic convenience aliases
    case success
    case warning
    case info

    var cssClasses: [String] {
        switch self {
        case .default: ["badge", "badge-default"]
        case .secondary: ["badge", "badge-secondary"]
        case .destructive: ["badge", "badge-destructive"]
        case .outline: ["badge", "badge-outline"]
        case .success: ["badge", "badge-success"]
        case .warning: ["badge", "badge-warning"]
        case .info: ["badge", "badge-info"]
        }
    }
}

struct BadgeStyleModifier: ViewModifier, Sendable {
    let variant: BadgeVariant
    var cssClasses: [String] { variant.cssClasses }
    var inlineStyles: [String: String] { [:] }
}
