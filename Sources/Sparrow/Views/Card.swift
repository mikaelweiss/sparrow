/// A card container with surface styling. Renders to a styled `<div>`.
public struct Card<Content: View>: View {
    public typealias Body = Never
    public let content: Content

    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    public var body: Never { fatalError("Card should not have body called") }
}

extension Card: Sendable where Content: Sendable {}
