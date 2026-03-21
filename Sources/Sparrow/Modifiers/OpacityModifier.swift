public struct OpacityModifier: ViewModifier, Sendable {
    public let opacity: Double

    public var inlineStyles: [String: String] {
        ["opacity": "\(opacity)"]
    }
}

extension View {
    public func opacity(_ opacity: Double) -> ModifiedView<Self, OpacityModifier> {
        modifier(OpacityModifier(opacity: opacity))
    }
}
