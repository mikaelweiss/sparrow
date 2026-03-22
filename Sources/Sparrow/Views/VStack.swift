/// A vertical stack layout. Renders to a flex-column div.
public struct VStack<Content: View>: View {
    public typealias Body = Never
    public let alignment: HorizontalAlignment
    public let spacing: Int
    public let content: Content

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never { fatalError("VStack should not have body called") }
}

extension VStack: Sendable where Content: Sendable {}

public enum HorizontalAlignment: Sendable {
    case leading, center, trailing, stretch

    var cssClass: String {
        switch self {
        case .leading: "items-start"
        case .center: "items-center"
        case .trailing: "items-end"
        case .stretch: "items-stretch"
        }
    }
}
