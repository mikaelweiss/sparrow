/// Adds a content transition effect so the client animates content changes
/// within this view (text changes, number counters, etc.).
public struct ContentTransitionModifier: ViewModifier, Sendable {
    public let transition: ContentTransition

    public var createsLayer: Bool { true }

    public var dataAttributes: [String: String] {
        switch transition {
        case .opacity:
            return ["data-sparrow-content-transition": "opacity"]
        case .numericText(let countsDown):
            return ["data-sparrow-content-transition": countsDown ? "numericDown" : "numericUp"]
        case .interpolate:
            return ["data-sparrow-content-transition": "interpolate"]
        }
    }

    public var inlineStyles: [String: String] {
        ["overflow": "hidden"]
    }
}

extension View {
    /// Control how content changes within this view are animated.
    public func contentTransition(_ transition: ContentTransition) -> ModifiedView<Self, ContentTransitionModifier> {
        modifier(ContentTransitionModifier(transition: transition))
    }
}
