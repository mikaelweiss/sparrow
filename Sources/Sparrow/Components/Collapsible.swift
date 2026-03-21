/// Collapsible component matching ShadCN Collapsible.
public struct Collapsible<Content: View>: View {
    let isOpen: Bool
    let content: Content
    public init(isOpen: Bool, @ViewBuilder content: () -> Content) {
        self.isOpen = isOpen
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .dataState(isOpen ? "open" : "closed")
    }
}

/// Collapsible trigger — PrimitiveView because it registers a click handler.
public struct CollapsibleTrigger: PrimitiveView, Sendable {
    public let label: String
    public let isOpen: Bool
    public let onToggle: @Sendable () -> Void
    public init(_ label: String, isOpen: Bool, onToggle: @escaping @Sendable () -> Void) {
        self.label = label
        self.isOpen = isOpen
        self.onToggle = onToggle
    }
}

/// Collapsible content — only renders when open.
public struct CollapsibleContent<Content: View>: View {
    let isOpen: Bool
    let content: Content
    public init(isOpen: Bool, @ViewBuilder content: () -> Content) {
        self.isOpen = isOpen
        self.content = content()
    }

    @ViewBuilder
    public var body: some View {
        if isOpen {
            VStack(alignment: .leading) {
                content
            }
        }
    }
}

extension Collapsible: Sendable where Content: Sendable {}
extension CollapsibleContent: Sendable where Content: Sendable {}
