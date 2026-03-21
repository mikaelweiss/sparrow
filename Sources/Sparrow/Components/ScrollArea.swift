/// ScrollArea with styled scrollbar matching ShadCN ScrollArea.
/// Uses the existing ScrollView primitive.
public struct ScrollArea<Content: View>: View {
    let axis: ScrollAreaAxis
    let content: Content
    public init(_ axis: ScrollAreaAxis = .vertical, @ViewBuilder content: () -> Content) {
        self.axis = axis
        self.content = content()
    }

    public var body: some View {
        ScrollView(scrollAxis) {
            content
        }
    }

    private var scrollAxis: ScrollAxis {
        switch axis {
        case .vertical: .vertical
        case .horizontal: .horizontal
        case .both: .both
        }
    }
}

public enum ScrollAreaAxis: Sendable { case vertical, horizontal, both }

extension ScrollArea: Sendable where Content: Sendable {}
