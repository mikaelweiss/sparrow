/// Accordion component matching ShadCN Accordion.
public struct Accordion<Content: View>: View {
    let type: AccordionType
    let content: Content
    public init(type: AccordionType = .single, @ViewBuilder content: () -> Content) {
        self.type = type
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
    }
}

public enum AccordionType: Sendable { case single, multiple }

/// A single accordion item with a trigger and collapsible content.
public struct AccordionItem<Content: View>: View {
    let value: String
    let isOpen: Bool
    let content: Content
    public init(value: String, isOpen: Bool = false, @ViewBuilder content: () -> Content) {
        self.value = value
        self.isOpen = isOpen
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .border(.border, edge: .bottom)
        .dataState(isOpen ? "open" : "closed")
    }
}

/// Accordion trigger button — PrimitiveView because it registers a click handler.
public struct AccordionTrigger: PrimitiveView, Sendable {
    public let text: String
    public let isOpen: Bool
    public let onToggle: @Sendable () -> Void
    public init(_ text: String, isOpen: Bool, onToggle: @escaping @Sendable () -> Void) {
        self.text = text
        self.isOpen = isOpen
        self.onToggle = onToggle
    }
}

/// Accordion content — only renders when open.
public struct AccordionContent<Content: View>: View {
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
            .padding(.bottom, 16)
        }
    }
}

extension Accordion: Sendable where Content: Sendable {}
extension AccordionItem: Sendable where Content: Sendable {}
extension AccordionContent: Sendable where Content: Sendable {}
