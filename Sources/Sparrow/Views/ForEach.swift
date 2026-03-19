/// Iterates over a collection and produces views for each element.
public struct ForEach<Data: Collection, Content: View>: View where Data: Sendable, Data.Element: Sendable {
    public typealias Body = Never
    public let data: Data
    public let content: @Sendable (Data.Element) -> Content

    public init(_ data: Data, @ViewBuilder content: @escaping @Sendable (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    public var body: Never { fatalError("ForEach should not have body called") }
}

extension ForEach: Sendable where Content: Sendable {}
