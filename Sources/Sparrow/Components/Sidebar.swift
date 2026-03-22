/// Sidebar layout matching ShadCN Sidebar.
/// VNodeRenderable because it produces a two-div structure (spacer + fixed container)
/// that can't be expressed through body composition alone.
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
        VStack(alignment: .stretch, spacing: 8) {
            content
        }
        .padding(8)
    }
}

public struct SidebarContent<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        ScrollView {
            VStack(alignment: .stretch, spacing: 8) {
                content
            }
        }
        .flex(1)
    }
}

public struct SidebarFooter<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .stretch, spacing: 8) {
            content
        }
        .padding(8)
    }
}

public struct SidebarGroup<Content: View>: View {
    let label: String?
    let content: Content
    public init(_ label: String? = nil, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .stretch) {
            if let label {
                SidebarGroupLabel(label)
            }
            content
        }
        .padding(8)
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
    public var body: some View { content }
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

/// PrimitiveView — clickable edge strip on sidebar border for toggling.
public struct SidebarRail: PrimitiveView, Sendable {
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

// Sidebar renders with the two-div trick: a spacer div in the flex flow
// and a fixed container pinned to the viewport edge.
extension Sidebar: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)

        // Spacer — reserves horizontal space in the parent flex layout
        let gapId = renderer.renderState.allocateId()
        let gap = ElementNode.build(tag: "div", id: gapId, classes: ["sidebar-gap"])

        // Inner flex column — holds children
        let innerId = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let inner = ElementNode.build(tag: "div", id: innerId, classes: ["sidebar-inner"], children: childNodes)

        // Fixed container — visible sidebar pinned to viewport
        let containerId = renderer.renderState.allocateId()
        let container = ElementNode.build(tag: "aside", id: containerId, classes: ["sidebar-container"], children: [.element(inner)])

        // Wrapper — coordinates data attributes for CSS descendant selectors
        let classes = ["sidebar"] + modifierContext.cssClasses
        var extraAttrs = modifierContext.allExtraAttributePairs
        extraAttrs.append((key: "data-state", value: isCollapsed ? "collapsed" : "expanded"))
        extraAttrs.append((key: "data-side", value: side == .left ? "left" : "right"))

        let el = ElementNode.build(
            tag: "div", id: id,
            classes: classes,
            styles: modifierContext.inlineStyles,
            extraAttrs: extraAttrs,
            children: [.element(gap), .element(container)]
        )
        return .element(el)
    }
}
