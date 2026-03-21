/// An icon-text pair. Composes HStack with Icon and Text.
public struct Label: View, Sendable {
    public let title: String
    public let icon: String

    public init(_ title: String, icon: String) {
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: 4) {
            Icon(icon)
            Text(title)
        }
        .modifier(LabelStyleModifier())
    }
}

struct LabelStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["label"] }
    var inlineStyles: [String: String] { [:] }
}
