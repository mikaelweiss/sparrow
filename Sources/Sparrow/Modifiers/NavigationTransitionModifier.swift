/// Controls the transition animation when navigating between pages.
/// Integrates with the View Transition API for smooth cross-page animations.
public struct NavigationTransitionModifier: ViewModifier, Sendable {
    public let style: NavigationTransitionStyle

    public var createsLayer: Bool { true }

    public var dataAttributes: [String: String] {
        switch style {
        case .automatic:
            return ["data-sparrow-nav-transition": "auto"]
        case .slide:
            return ["data-sparrow-nav-transition": "slide"]
        case .zoom:
            return ["data-sparrow-nav-transition": "zoom"]
        }
    }

    public var inlineStyles: [String: String] {
        ["view-transition-name": "sparrow-page"]
    }
}

extension View {
    /// Set the navigation transition style for this view.
    public func navigationTransition(_ style: NavigationTransitionStyle) -> ModifiedView<Self, NavigationTransitionModifier> {
        modifier(NavigationTransitionModifier(style: style))
    }
}
