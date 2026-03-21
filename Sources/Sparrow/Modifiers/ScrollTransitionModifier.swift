/// Adds scroll-triggered animations via IntersectionObserver.
/// The view starts in a "from" state and transitions to a "to" state
/// when it enters the viewport.
public struct ScrollTransitionModifier: ViewModifier, Sendable {
    public let axis: ScrollAxis
    public let transition: SparrowTransition
    public let animation: SparrowAnimation

    public enum ScrollAxis: String, Sendable {
        case vertical, horizontal
    }

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
        attrs["data-sparrow-scroll-transition"] = axis.rawValue
        if !transition.enterToClasses.isEmpty {
            attrs["data-sparrow-scroll-to"] = transition.enterToClasses.joined(separator: " ")
        }
        if !transition.enterFromClasses.isEmpty {
            attrs["data-sparrow-scroll-from"] = transition.enterFromClasses.joined(separator: " ")
        }
        return attrs
    }
}

extension View {
    /// Animate this view when it scrolls into the viewport.
    public func scrollTransition(
        _ axis: ScrollTransitionModifier.ScrollAxis = .vertical,
        transition: SparrowTransition = .opacity,
        animation: SparrowAnimation = .default
    ) -> ModifiedView<Self, ScrollTransitionModifier> {
        modifier(ScrollTransitionModifier(axis: axis, transition: transition, animation: animation))
    }
}
