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
}

extension ViewModifier {
    public var cssClasses: [String] { [] }
    public var inlineStyles: [String: String] { [:] }
}

extension View {
    /// Apply a modifier to this view.
    public func modifier<M: ViewModifier>(_ modifier: M) -> ModifiedView<Self, M> {
        ModifiedView(content: self, modifier: modifier)
    }
}
