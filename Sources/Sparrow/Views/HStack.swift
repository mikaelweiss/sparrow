/// A horizontal stack layout. Renders to a flex-row div.
public struct HStack<Content: View>: View {
    public typealias Body = Never
    public let alignment: VerticalAlignment
    public let spacing: Int
    public let content: Content

    public init(
        alignment: VerticalAlignment = .center,
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never { fatalError("HStack should not have body called") }
}

extension HStack: Sendable where Content: Sendable {}

public enum VerticalAlignment: Sendable {
    case top, center, bottom

    var cssClass: String {
        switch self {
        case .top: "items-start"
        case .center: "items-center"
        case .bottom: "items-end"
        }
    }
}
