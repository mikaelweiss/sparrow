public struct FocusRingModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["focus-ring"] }
}

extension View {
    public func focusRing() -> ModifiedView<Self, FocusRingModifier> {
        modifier(FocusRingModifier())
    }
}
