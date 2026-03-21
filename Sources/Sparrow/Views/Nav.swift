/// A semantic navigation container. Renders to `<nav>`.
public struct Nav<Content: View>: View {
    public typealias Body = Never
    let ariaLabel: String?
    let content: Content

    public init(
        ariaLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.ariaLabel = ariaLabel
        self.content = content()
    }

    public var body: Never { fatalError("Nav should not have body called") }
}

extension Nav: Sendable where Content: Sendable {}
