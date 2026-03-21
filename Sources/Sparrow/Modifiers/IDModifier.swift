/// Sets a custom HTML id attribute on a view element.
/// Used for anchor/fragment links (`#section`).
public struct IDModifier: ViewModifier, Sendable {
    public let identifier: String
    public var cssClasses: [String] { [] }
    public var inlineStyles: [String: String] { [:] }
    public var createsLayer: Bool { false }
}

extension View {
    /// Set an anchor ID on this view for fragment links (`#section`).
    public func id(_ identifier: String) -> ModifiedView<Self, IDModifier> {
        modifier(IDModifier(identifier: identifier))
    }
}
