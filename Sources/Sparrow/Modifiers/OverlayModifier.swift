public struct ClippedModifier: ViewModifier, Sendable {
    public var createsLayer: Bool { true }
    public var cssClasses: [String] { ["overflow-hidden"] }
}

extension View {
    public func clipped() -> ModifiedView<Self, ClippedModifier> {
        modifier(ClippedModifier())
    }
}
