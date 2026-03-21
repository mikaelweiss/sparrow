/// Enables shared element transitions between views using the View Transition API.
/// Elements with the same `id` and `namespace` will animate between their old
/// and new positions/sizes when DOM patches are applied via `startViewTransition()`.
public struct MatchedGeometryModifier: ViewModifier, Sendable {
    public let matchId: String
    public let namespace: String

    public var inlineStyles: [String: String] {
        ["view-transition-name": "\(namespace)-\(matchId)"]
    }
}

extension View {
    /// Mark this view as a participant in a shared element transition.
    /// Views with the same `id` and `namespace` will morph between positions during navigation.
    public func matchedGeometryEffect(id: String, in namespace: String) -> ModifiedView<Self, MatchedGeometryModifier> {
        modifier(MatchedGeometryModifier(matchId: id, namespace: namespace))
    }
}
