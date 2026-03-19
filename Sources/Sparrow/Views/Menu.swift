/// A dropdown menu. Renders to a `<div>` with dropdown behavior.
public struct Menu<Content: View>: View {
    public typealias Body = Never
    public let label: String
    public let content: Content

    public init(
        _ label: String,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.content = content()
    }

    public var body: Never { fatalError("Menu should not have body called") }
}

extension Menu: Sendable where Content: Sendable {}
