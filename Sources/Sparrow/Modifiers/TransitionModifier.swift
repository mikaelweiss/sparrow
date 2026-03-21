/// Wraps a view with enter/exit animation support.
/// Creates a layer div with data attributes that the client's presence system
/// reads to animate appearance and disappearance.
public struct TransitionModifier: ViewModifier, Sendable {
    public let transition: SparrowTransition
    public let animation: SparrowAnimation

    public var createsLayer: Bool { true }

    public var cssClasses: [String] {
        transition.enterFromClasses
    }

    public var inlineStyles: [String: String] {
        guard !transition.transitionProperties.isEmpty else { return [:] }
        return [
            "transition-property": transition.transitionProperties,
            "transition-duration": animation.formatDuration(animation.duration),
            "transition-timing-function": animation.timingFunction,
        ]
    }

    public var dataAttributes: [String: String] {
        var attrs: [String: String] = [:]
        if !transition.enterToClasses.isEmpty {
            attrs["data-sparrow-enter"] = transition.enterToClasses.joined(separator: " ")
        }
        if !transition.enterFromClasses.isEmpty {
            attrs["data-sparrow-enter-from"] = transition.enterFromClasses.joined(separator: " ")
        }
        if !transition.exitToClasses.isEmpty {
            attrs["data-sparrow-exit"] = transition.exitToClasses.joined(separator: " ")
        }
        // On exit, remove the enter-to classes so the exit-to classes take effect
        if !transition.enterToClasses.isEmpty {
            attrs["data-sparrow-exit-from"] = transition.enterToClasses.joined(separator: " ")
        }
        return attrs
    }
}

extension View {
    /// Apply an enter/exit transition to this view.
    public func transition(_ transition: SparrowTransition, animation: SparrowAnimation = .default) -> ModifiedView<Self, TransitionModifier> {
        modifier(TransitionModifier(transition: transition, animation: animation))
    }
}
