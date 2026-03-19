/// A CSS grid layout. Renders to a div with display: grid.
public struct Grid<Content: View>: View {
    public typealias Body = Never
    public let columns: Int
    public let spacing: Int
    public let content: Content

    public init(
        columns: Int = 2,
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.columns = columns
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never { fatalError("Grid should not have body called") }
}

extension Grid: Sendable where Content: Sendable {}
