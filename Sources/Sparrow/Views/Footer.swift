/// A page footer with arbitrary content.
/// Renders as a semantic `<footer>` element pinned to the bottom of its container.
public struct Footer<Content: View>: View {
    public typealias Body = Never
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("Footer should not have body called") }
}

extension Footer: Sendable where Content: Sendable {}

/// A column of links inside a Footer. Renders as a `<nav>` with a heading.
/// Use inside a Footer to create multi-column link grids.
public struct FooterColumn<Content: View>: View {
    public typealias Body = Never
    public let heading: String
    public let content: Content

    public init(_ heading: String, @ViewBuilder content: () -> Content) {
        self.heading = heading
        self.content = content()
    }

    public var body: Never { fatalError("FooterColumn should not have body called") }
}

extension FooterColumn: Sendable where Content: Sendable {}

/// The bottom bar of a footer — typically copyright and legal links.
/// Renders below a divider in smaller text.
public struct FooterBottom<Content: View>: View {
    public typealias Body = Never
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("FooterBottom should not have body called") }
}

extension FooterBottom: Sendable where Content: Sendable {}
