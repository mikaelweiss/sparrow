public struct NavigationTitleModifier: ViewModifier, Sendable {
    public let title: String
    public var htmlAttributes: [String: String] { ["data-sparrow-title": title] }
}

extension View {
    public func navigationTitle(_ title: String) -> ModifiedView<Self, NavigationTitleModifier> {
        modifier(NavigationTitleModifier(title: title))
    }
}

public struct NavigationBarHiddenModifier: ViewModifier, Sendable {
    public let hidden: Bool
    public var htmlAttributes: [String: String] { ["data-sparrow-nav-hidden": hidden ? "true" : "false"] }
}

extension View {
    public func navigationBarHidden(_ hidden: Bool) -> ModifiedView<Self, NavigationBarHiddenModifier> {
        modifier(NavigationBarHiddenModifier(hidden: hidden))
    }
}

public struct NavigationBackButtonHiddenModifier: ViewModifier, Sendable {
    public let hidden: Bool
    public var htmlAttributes: [String: String] { ["data-sparrow-back-hidden": hidden ? "true" : "false"] }
}

extension View {
    public func navigationBarBackButtonHidden(_ hidden: Bool = true) -> ModifiedView<Self, NavigationBackButtonHiddenModifier> {
        modifier(NavigationBackButtonHiddenModifier(hidden: hidden))
    }
}
