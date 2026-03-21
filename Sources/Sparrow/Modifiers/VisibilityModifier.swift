public struct HiddenModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["hidden"] }
}

extension View {
    public func hidden() -> ModifiedView<Self, HiddenModifier> {
        modifier(HiddenModifier())
    }
}

public enum RedactedReason: Sendable {
    case placeholder
}

public struct RedactedModifier: ViewModifier, Sendable {
    public let reason: RedactedReason
    public var cssClasses: [String] { ["redacted"] }
}

extension View {
    public func redacted(reason: RedactedReason) -> ModifiedView<Self, RedactedModifier> {
        modifier(RedactedModifier(reason: reason))
    }
}
