/// A styled list container. Renders to `<ul>` or `<ol>`.
public struct List<Content: View>: View {
    public typealias Body = Never
    public let ordered: Bool
    public let content: Content

    public init(
        ordered: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.ordered = ordered
        self.content = content()
    }

    public var body: Never { fatalError("List should not have body called") }
}

extension List: Sendable where Content: Sendable {}
