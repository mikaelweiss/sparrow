/// Grouped content with an optional header. Renders to `<section>`.
public struct Section<Content: View>: View {
    public typealias Body = Never
    public let header: String?
    public let content: Content

    public init(
        header: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.content = content()
    }

    public var body: Never { fatalError("Section should not have body called") }
}

extension Section: Sendable where Content: Sendable {}
