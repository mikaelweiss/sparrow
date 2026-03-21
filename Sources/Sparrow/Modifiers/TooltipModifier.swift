public struct HelpModifier: ViewModifier, Sendable {
    public let text: String
    public var htmlAttributes: [String: String] { ["title": text] }
}

extension View {
    public func help(_ text: String) -> ModifiedView<Self, HelpModifier> {
        modifier(HelpModifier(text: text))
    }
}
