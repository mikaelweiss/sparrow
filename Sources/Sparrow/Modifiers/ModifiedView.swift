/// A view that wraps another view with a modifier applied.
public struct ModifiedView<Content: View, Modifier: ViewModifier>: View {
    public typealias Body = Never
    public let content: Content
    public let modifier: Modifier

    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }

    public var body: Never { fatalError("ModifiedView should not have body called") }
}

extension ModifiedView: Sendable where Content: Sendable, Modifier: Sendable {}

/// A modifier that transforms a view's rendering.
public protocol ViewModifier: Sendable {
    /// The CSS classes this modifier adds.
    var cssClasses: [String] { get }
    /// Inline styles this modifier adds (for values not in the design system).
    var inlineStyles: [String: String] { get }
    /// Layer modifiers create a wrapper `<div>` so that ordering is respected.
    /// Flat modifiers (font, foreground color) accumulate onto the leaf element.
    var createsLayer: Bool { get }
    /// HTML data attributes this modifier adds (e.g., for animation/transition hooks).
    var dataAttributes: [String: String] { get }
}

extension ViewModifier {
    public var cssClasses: [String] { [] }
    public var inlineStyles: [String: String] { [:] }
    public var createsLayer: Bool { false }
    public var dataAttributes: [String: String] { [:] }
}

extension View {
    /// Apply a modifier to this view.
    public func modifier<M: ViewModifier>(_ modifier: M) -> ModifiedView<Self, M> {
        ModifiedView(content: self, modifier: modifier)
    }
}
