/// Border radius tokens from the design system.
public enum CornerRadius: Sendable {
    case none
    case sm
    case md
    case lg
    case xl
    case xxl
    case full

    var cssClass: String {
        switch self {
        case .none: "rounded-none"
        case .sm: "rounded-sm"
        case .md: "rounded-md"
        case .lg: "rounded-lg"
        case .xl: "rounded-xl"
        case .xxl: "rounded-2xl"
        case .full: "rounded-full"
        }
    }
}

public struct CornerRadiusModifier: ViewModifier, Sendable {
    public let radius: CornerRadius
    public var cssClasses: [String] { [radius.cssClass] }
    public var inlineStyles: [String: String] { [:] }
}

extension View {
    public func cornerRadius(_ radius: CornerRadius) -> ModifiedView<Self, CornerRadiusModifier> {
        modifier(CornerRadiusModifier(radius: radius))
    }
}
