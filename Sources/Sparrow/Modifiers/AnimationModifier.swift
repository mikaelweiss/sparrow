/// Adds CSS transitions to a view so property changes animate instead of snapping.
/// When state changes cause re-renders, the browser automatically transitions
/// because the element already has `transition` CSS applied.
public struct AnimationModifier: ViewModifier, Sendable {
    public let animation: SparrowAnimation

    public var inlineStyles: [String: String] {
        ["transition": animation.cssTransition]
    }
}

/// Disables animation on a view by removing transitions.
public struct AnimationDisabledModifier: ViewModifier, Sendable {
    public var inlineStyles: [String: String] {
        ["transition": "none"]
    }
}

extension View {
    /// Animate all property changes on this view with the given curve.
    public func animation(_ animation: SparrowAnimation) -> ModifiedView<Self, AnimationModifier> {
        modifier(AnimationModifier(animation: animation))
    }

    /// Animate property changes when `value` changes.
    /// In server-rendered Sparrow, this always applies the transition CSS —
    /// the browser handles diffing which properties actually changed.
    public func animation<V: Equatable>(_ animation: SparrowAnimation, value: V) -> ModifiedView<Self, AnimationModifier> {
        modifier(AnimationModifier(animation: animation))
    }

    /// Disable animations on this view.
    public func animation(_ animation: SparrowAnimation?) -> ModifiedView<Self, AnimationDisabledModifier> where SparrowAnimation? == Optional<SparrowAnimation> {
        modifier(AnimationDisabledModifier())
    }
}
