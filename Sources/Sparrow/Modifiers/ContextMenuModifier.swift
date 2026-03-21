public struct ContextMenuModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["context-menu-target"] }
    public var htmlAttributes: [String: String] { ["data-sparrow-context-menu": "true"] }
    public var createsLayer: Bool { true }
}

extension View {
    public func contextMenu() -> ModifiedView<Self, ContextMenuModifier> {
        modifier(ContextMenuModifier())
    }
}
