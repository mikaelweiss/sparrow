/// Sidebar layout matching ShadCN Sidebar.
/// VNodeRenderable because it renders as `<aside>` (no primitive for that).
public struct Sidebar<Content: View>: View {
    let side: SidebarSide
    let isCollapsed: Bool
    let content: Content
    public init(side: SidebarSide = .left, isCollapsed: Bool = false, @ViewBuilder content: () -> Content) {
        self.side = side
        self.isCollapsed = isCollapsed
        self.content = content()
    }
    public var body: Never { fatalError() }
}

public struct SidebarHeader<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(16)
    }
}

public struct SidebarContent<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(16)
    }
}

public struct SidebarFooter<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(16)
    }
}

public struct SidebarGroup<Content: View>: View {
    let label: String?
    let content: Content
    public init(_ label: String? = nil, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    @ViewBuilder
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foreground(.mutedForeground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
            content
        }
    }
}

/// PrimitiveView — text label in sidebar.
public struct SidebarGroupLabel: PrimitiveView, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }
}

public struct SidebarMenuItem<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
    }
}

/// PrimitiveView — registers click handler.
public struct SidebarMenuButton: PrimitiveView, Sendable {
    public let label: String
    public let isActive: Bool
    public let action: @Sendable () -> Void
    public init(_ label: String, isActive: Bool = false, action: @escaping @Sendable () -> Void) {
        self.label = label
        self.isActive = isActive
        self.action = action
    }
}

/// PrimitiveView — registers click handler.
public struct SidebarTrigger: PrimitiveView, Sendable {
    public let onToggle: @Sendable () -> Void
    public init(onToggle: @escaping @Sendable () -> Void) { self.onToggle = onToggle }
}

public enum SidebarSide: Sendable { case left, right }

extension Sidebar: Sendable where Content: Sendable {}
extension SidebarHeader: Sendable where Content: Sendable {}
extension SidebarContent: Sendable where Content: Sendable {}
extension SidebarFooter: Sendable where Content: Sendable {}
extension SidebarGroup: Sendable where Content: Sendable {}
extension SidebarMenuItem: Sendable where Content: Sendable {}

// Sidebar renders as <aside> — no primitive for this tag.
extension Sidebar: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        var classes = ["sidebar"] + modifierContext.cssClasses
        if side == .right { classes.append("sidebar-right") }
        if isCollapsed { classes.append("sidebar-collapsed") }
        var extraAttrs = modifierContext.allExtraAttributePairs
        extraAttrs.append((key: "data-state", value: isCollapsed ? "collapsed" : "expanded"))
        let el = ElementNode.build(tag: "aside", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: extraAttrs, children: childNodes)
        return .element(el)
    }
}
