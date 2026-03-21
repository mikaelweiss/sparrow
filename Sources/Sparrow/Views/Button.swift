/// A clickable button. Renders to `<button>` with event forwarding over WebSocket.
///
/// Variants and sizes match shadcn Button exactly:
/// - Variants: default, destructive, outline, secondary, ghost, link
/// - Sizes: default, sm, lg, icon
public struct Button: PrimitiveView, Sendable {
    public let label: String
    public let variant: ButtonVariant
    public let size: ButtonSize
    public let action: @Sendable () -> Void

    public init(
        _ label: String,
        variant: ButtonVariant = .default,
        size: ButtonSize = .default,
        action: @escaping @Sendable () -> Void
    ) {
        self.label = label
        self.variant = variant
        self.size = size
        self.action = action
    }
}

/// Button visual variants matching shadcn.
public enum ButtonVariant: Sendable {
    case `default`
    case destructive
    case outline
    case secondary
    case ghost
    case link

    var cssClass: String {
        switch self {
        case .default: "btn-default"
        case .destructive: "btn-destructive"
        case .outline: "btn-outline"
        case .secondary: "btn-secondary"
        case .ghost: "btn-ghost"
        case .link: "btn-link"
        }
    }
}

/// Button sizes matching shadcn.
public enum ButtonSize: Sendable {
    case `default`
    case sm
    case lg
    case icon

    var cssClass: String {
        switch self {
        case .default: "btn-md"
        case .sm: "btn-sm"
        case .lg: "btn-lg"
        case .icon: "btn-icon"
        }
    }
}
