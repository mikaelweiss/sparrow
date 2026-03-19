/// A vertical list of collapsible sections. Renders to multiple `<details>` elements.
public struct Accordion: PrimitiveView, Sendable {
    public let items: [AccordionItem]
    public let allowMultiple: Bool

    public init(items: [AccordionItem], allowMultiple: Bool = false) {
        self.items = items
        self.allowMultiple = allowMultiple
    }
}

public struct AccordionItem: Sendable {
    public let label: String
    public let content: String
    public let isExpanded: Bool

    public init(label: String, content: String, isExpanded: Bool = false) {
        self.label = label
        self.content = content
        self.isExpanded = isExpanded
    }
}
