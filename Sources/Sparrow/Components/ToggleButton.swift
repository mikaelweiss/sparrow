/// Toggle button component matching ShadCN Toggle (not Switch).
public struct ToggleButton: PrimitiveView, Sendable {
    public let label: String
    public let isPressed: Bool
    public let variant: ToggleButtonVariant
    public let size: ToggleButtonSize
    public let onToggle: @Sendable () -> Void

    public init(_ label: String, isPressed: Bool, variant: ToggleButtonVariant = .default, size: ToggleButtonSize = .default, onToggle: @escaping @Sendable () -> Void) {
        self.label = label
        self.isPressed = isPressed
        self.variant = variant
        self.size = size
        self.onToggle = onToggle
    }
}

public enum ToggleButtonVariant: Sendable {
    case `default`, outline

    var cssClass: String {
        switch self {
        case .default: "toggle-btn-default"
        case .outline: "toggle-btn-outline"
        }
    }
}

public enum ToggleButtonSize: Sendable {
    case `default`, sm, lg

    var cssClass: String {
        switch self {
        case .default: "toggle-btn-md"
        case .sm: "toggle-btn-sm"
        case .lg: "toggle-btn-lg"
        }
    }
}
