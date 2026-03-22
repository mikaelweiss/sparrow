/// An overlay stack layout. Renders to a position-relative div with absolutely-positioned children.
public struct ZStack<Content: View>: View {
    public typealias Body = Never
    public let alignment: Alignment
    public let content: Content

    public init(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.content = content()
    }

    public var body: Never { fatalError("ZStack should not have body called") }
}

extension ZStack: Sendable where Content: Sendable {}

public struct Alignment: Sendable {
    public let horizontal: HorizontalAlignment
    public let vertical: VerticalAlignment

    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    public static let center = Alignment(horizontal: .center, vertical: .center)
    public static let topLeading = Alignment(horizontal: .leading, vertical: .top)
    public static let top = Alignment(horizontal: .center, vertical: .top)
    public static let topTrailing = Alignment(horizontal: .trailing, vertical: .top)
    public static let leading = Alignment(horizontal: .leading, vertical: .center)
    public static let trailing = Alignment(horizontal: .trailing, vertical: .center)
    public static let bottomLeading = Alignment(horizontal: .leading, vertical: .bottom)
    public static let bottom = Alignment(horizontal: .center, vertical: .bottom)
    public static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)

    var justifyCss: String {
        switch horizontal {
        case .leading: "justify-start"
        case .center: "justify-center"
        case .trailing: "justify-end"
        case .stretch: "justify-stretch"
        }
    }

    var alignCss: String {
        switch vertical {
        case .top: "items-start"
        case .center: "items-center"
        case .bottom: "items-end"
        }
    }
}
