/// Border radius tokens from the design system.
public enum CornerRadius: Sendable {
    case none
    case sm
    case md
    case lg
    case xl
    case xxl
    case xxxl
    case full

    var cssClass: String {
        switch self {
        case .none: "rounded-none"
        case .sm: "rounded-sm"
        case .md: "rounded-md"
        case .lg: "rounded-lg"
        case .xl: "rounded-xl"
        case .xxl: "rounded-2xl"
        case .xxxl: "rounded-3xl"
        case .full: "rounded-full"
        }
    }
}

/// Corner shape controls the curvature profile of rounded corners.
public enum CornerShape: Sendable {
    /// Standard circular arc (CSS default).
    case round
    /// Smooth superellipse curve (Apple-style continuous corners).
    case squircle
}

public struct CornerRadiusModifier: ViewModifier, Sendable {
    public let radius: CornerRadius
    public let shape: CornerShape

    public var createsLayer: Bool { true }
    public var cssClasses: [String] { [radius.cssClass] }
    public var inlineStyles: [String: String] {
        switch shape {
        case .round: ["overflow": "hidden"]
        case .squircle: ["overflow": "hidden", "corner-shape": "squircle"]
        }
    }
}

extension View {
    public func cornerRadius(_ radius: CornerRadius, shape: CornerShape = .round) -> ModifiedView<Self, CornerRadiusModifier> {
        modifier(CornerRadiusModifier(radius: radius, shape: shape))
    }
}
