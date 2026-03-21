/// Badge component matching ShadCN Badge.
public struct Badge: View, Sendable {
    public let text: String
    public let variant: BadgeVariant

    public init(_ text: String, variant: BadgeVariant = .default) {
        self.text = text
        self.variant = variant
    }

    public var body: some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            .cornerRadius(.full)
            .border(variant == .outline ? .border : .clear)
            .background(variant.backgroundColor)
            .foreground(variant.foregroundColor)
            .hoverStyle(.background(variant.hoverColor))
    }
}

public enum BadgeVariant: Sendable {
    case `default`
    case secondary
    case outline
    case destructive

    var backgroundColor: SemanticColor {
        switch self {
        case .default: .primary
        case .secondary: .secondary
        case .outline: .clear
        case .destructive: .error
        }
    }

    var foregroundColor: SemanticColor {
        switch self {
        case .default: .background
        case .secondary: .text
        case .outline: .text
        case .destructive: .destructiveForeground
        }
    }

    var hoverColor: SemanticColor {
        switch self {
        case .default: .primary.opacity(0.8)
        case .secondary: .secondary.opacity(0.8)
        case .outline: .accent
        case .destructive: .error.opacity(0.8)
        }
    }
}
