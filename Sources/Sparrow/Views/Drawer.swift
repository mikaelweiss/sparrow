/// A panel that slides in from the edge.
/// On mobile: slides up from bottom. On desktop: slides in from the specified edge.
public struct Drawer<Content: View>: View {
    public typealias Body = Never
    public let isPresented: Bool
    public let edge: DrawerEdge
    public let content: Content

    public init(
        isPresented: Bool,
        edge: DrawerEdge = .trailing,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented
        self.edge = edge
        self.content = content()
    }

    public var body: Never { fatalError("Drawer should not have body called") }

    public enum DrawerEdge: String, Sendable {
        case leading
        case trailing
        case bottom
    }
}

extension Drawer: Sendable where Content: Sendable {}
