/// A breadcrumb trail for hierarchical navigation. Desktop-only: hidden on mobile.
public struct Breadcrumb: PrimitiveView, Sendable {
    public let items: [BreadcrumbItem]

    public init(items: [BreadcrumbItem]) {
        self.items = items
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
