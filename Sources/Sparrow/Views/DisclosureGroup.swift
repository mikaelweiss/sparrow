/// A collapsible section. Renders to `<details>` with `<summary>`.
public struct DisclosureGroup<Content: View>: View {
    public typealias Body = Never
    public let label: String
    public let isExpanded: Bool
    public let content: Content

    public init(
        _ label: String,
        isExpanded: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.isExpanded = isExpanded
        self.content = content()
    }

    public var body: Never { fatalError("DisclosureGroup should not have body called") }
}

extension DisclosureGroup: Sendable where Content: Sendable {}
