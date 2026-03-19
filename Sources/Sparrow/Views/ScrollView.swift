/// A scrollable container. Renders to a div with overflow scroll.
public struct ScrollView<Content: View>: View {
    public typealias Body = Never
    public let axis: ScrollAxis
    public let content: Content

    public init(
        _ axis: ScrollAxis = .vertical,
        @ViewBuilder content: () -> Content
    ) {
        self.axis = axis
        self.content = content()
    }

    public var body: Never { fatalError("ScrollView should not have body called") }
}

extension ScrollView: Sendable where Content: Sendable {}

public enum ScrollAxis: Sendable {
    case vertical, horizontal, both
}
