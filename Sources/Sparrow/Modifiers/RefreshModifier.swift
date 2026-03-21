public struct RefreshableModifier: ViewModifier, EventModifying, Sendable {
    public let action: @Sendable () async -> Void

    public var cssClasses: [String] { ["refreshable"] }
    public var createsLayer: Bool { true }
    public var eventAttributes: [String: String] { ["data-sparrow-event": "refresh"] }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id) { Task { await action() } }
    }
}

extension View {
    public func refreshable(action: @escaping @Sendable () async -> Void) -> ModifiedView<Self, RefreshableModifier> {
        modifier(RefreshableModifier(action: action))
    }
}
