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
