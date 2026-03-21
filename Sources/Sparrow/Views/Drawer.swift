/// A panel that slides in from the edge.
///
/// Uses client runtime primitives:
/// - FocusTrap: traps Tab cycling within the drawer
/// - DismissableLayer: Escape key and outside click dismiss
/// - Presence: slide-in/out animations
public struct Drawer<Content: View>: View {
    public typealias Body = Never
    public let isPresented: Bool
    let isPresentedBinding: Binding<Bool>?
    public let edge: DrawerEdge
    public let content: Content

    public init(
        isPresented: Bool,
        edge: DrawerEdge = .trailing,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented
        self.isPresentedBinding = nil
        self.edge = edge
        self.content = content()
    }

    public init(
        isPresented: Binding<Bool>,
        edge: DrawerEdge = .trailing,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented.wrappedValue
        self.isPresentedBinding = isPresented
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
