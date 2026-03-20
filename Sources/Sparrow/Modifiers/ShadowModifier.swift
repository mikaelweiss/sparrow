/// Shadow tokens from the design system.
public enum Shadow: Sendable {
    case none
    case sm
    case md
    case lg
    case xl

    var cssClass: String {
        switch self {
        case .none: "shadow-none"
        case .sm: "shadow-sm"
        case .md: "shadow-md"
        case .lg: "shadow-lg"
        case .xl: "shadow-xl"
        }
    }
}

public struct ShadowModifier: ViewModifier, Sendable {
    public let shadow: Shadow
    public var createsLayer: Bool { true }
    public var cssClasses: [String] { [shadow.cssClass] }
    public var inlineStyles: [String: String] { [:] }
}

extension View {
    public func shadow(_ shadow: Shadow) -> ModifiedView<Self, ShadowModifier> {
        modifier(ShadowModifier(shadow: shadow))
    }
}
