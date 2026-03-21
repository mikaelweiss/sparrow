/// Navigation menu matching ShadCN NavigationMenu.
public struct NavigationMenu<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: Never { fatalError() }
}

public struct NavigationMenuItem<Trigger: View, MenuContent: View>: View {
    let isOpen: Bool
    let onToggle: @Sendable () -> Void
    let onDismiss: @Sendable () -> Void
    let trigger: Trigger
    let menuContent: MenuContent
    public init(isOpen: Bool, onToggle: @escaping @Sendable () -> Void, onDismiss: @escaping @Sendable () -> Void, @ViewBuilder trigger: () -> Trigger, @ViewBuilder content: () -> MenuContent) {
        self.isOpen = isOpen
        self.onToggle = onToggle
        self.onDismiss = onDismiss
        self.trigger = trigger()
        self.menuContent = content()
    }
    public var body: Never { fatalError() }
}

public struct NavigationMenuTrigger: PrimitiveView, Sendable {
    public let label: String
    public let isOpen: Bool
    public init(_ label: String, isOpen: Bool = false) {
        self.label = label
        self.isOpen = isOpen
    }
}

public struct NavigationMenuLink: PrimitiveView, Sendable {
    public let label: String
    public let href: String
    public init(_ label: String, href: String) {
        self.label = label
        self.href = href
    }
}

extension NavigationMenu: Sendable where Content: Sendable {}
extension NavigationMenuItem: Sendable where Trigger: Sendable, MenuContent: Sendable {}

extension NavigationMenu: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["nav-menu"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "nav", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: childNodes)
        return .element(el)
    }
}

extension NavigationMenuItem: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let triggerId = renderer.renderState.allocateId()
        renderer.renderState.registerHandler(id: triggerId, handler: onToggle)
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())
        var allChildren: [VNode] = [triggerNode]

        if isOpen {
            let contentId = renderer.renderState.allocateId()
            let menuNodes = renderer.renderChildrenVNodes(flattenChildren(menuContent))
            let contentAttrs: [(key: String, value: String)] = [
                (key: "data-sparrow-floating", value: "bottom"),
                (key: "data-sparrow-floating-anchor", value: triggerId),
                (key: "data-sparrow-dismissable", value: triggerId)
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["nav-menu-content"], extraAttrs: contentAttrs, children: menuNodes)
            allChildren.append(.element(contentEl))
        }

        let classes = ["nav-menu-item"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }
}
