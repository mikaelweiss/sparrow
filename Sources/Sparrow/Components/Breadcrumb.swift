/// Breadcrumb navigation matching ShadCN Breadcrumb.
/// BreadcrumbLink, BreadcrumbSeparator, BreadcrumbPage are PrimitiveViews
/// because they render specific HTML elements (<a>, <li>, <span>).
public struct Breadcrumb<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        Nav(ariaLabel: "breadcrumb") {
            HStack(spacing: 4) {
                content
            }
        }
    }
}

public struct BreadcrumbItem<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack(spacing: 4) {
            content
        }
    }
}

/// Renders to `<a>` or `<span>` — PrimitiveView because Text can't render anchors.
public struct BreadcrumbLink: PrimitiveView, Sendable {
    public let text: String
    public let href: String?
    public init(_ text: String, href: String? = nil) {
        self.text = text
        self.href = href
    }
}

/// Renders a separator character in a breadcrumb trail.
public struct BreadcrumbSeparator: PrimitiveView, Sendable {
    public init() {}
}

/// Renders the current page label — PrimitiveView for aria-current attribute.
public struct BreadcrumbPage: PrimitiveView, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }
}

extension Breadcrumb: Sendable where Content: Sendable {}
extension BreadcrumbItem: Sendable where Content: Sendable {}
