/// A breadcrumb trail for hierarchical navigation.
/// Composes NavigationLink and Text with separator spans.
public struct Breadcrumb: View, Sendable {
    public let items: [BreadcrumbItem]

    public init(items: [BreadcrumbItem]) {
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(items.enumerated()), content: { index, item in
                if index > 0 {
                    Text("/")
                        .modifier(BreadcrumbSepStyleModifier())
                }
                if let dest = item.destination, index < items.count - 1 {
                    NavigationLink(item.label, destination: dest)
                        .modifier(BreadcrumbLinkStyleModifier())
                } else {
                    Text(item.label)
                        .modifier(BreadcrumbCurrentStyleModifier())
                }
            })
        }
        .modifier(BreadcrumbStyleModifier())
    }
}

public struct BreadcrumbItem: Sendable {
    public let label: String
    public let destination: String?

    public init(_ label: String, destination: String? = nil) {
        self.label = label
        self.destination = destination
    }
}

struct BreadcrumbStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["breadcrumb", "desktop-only"] }
}

struct BreadcrumbSepStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["breadcrumb-sep"] }
}

struct BreadcrumbLinkStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["breadcrumb-link"] }
}

struct BreadcrumbCurrentStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["breadcrumb-current"] }
}
