/// Context menu (right-click) matching ShadCN ContextMenu.
/// Reuses DropdownMenuItem/Separator/Label for menu content.
public struct ContextMenu<Trigger: View, MenuContent: View>: View {
    let isOpen: Bool
    let onOpenChange: @Sendable (Bool) -> Void
    let trigger: Trigger
    let menuContent: MenuContent
    public init(isOpen: Bool, onOpenChange: @escaping @Sendable (Bool) -> Void, @ViewBuilder trigger: () -> Trigger, @ViewBuilder content: () -> MenuContent) {
        self.isOpen = isOpen
        self.onOpenChange = onOpenChange
        self.trigger = trigger()
        self.menuContent = content()
    }
    public var body: Never { fatalError() }
}

extension ContextMenu: Sendable where Trigger: Sendable, MenuContent: Sendable {}

extension ContextMenu: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let triggerId = renderer.renderState.allocateId()
        // contextmenu event handler — client JS sends this on right-click
        renderer.renderState.registerHandler(id: triggerId) { [onOpenChange] in onOpenChange(true) }
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())

        var allChildren: [VNode] = [triggerNode]

        if isOpen {
            let contentId = renderer.renderState.allocateId()
            let dismissId = renderer.renderState.allocateId()
            renderer.renderState.registerHandler(id: dismissId) { [onOpenChange] in onOpenChange(false) }
            let menuNodes = renderer.renderChildrenVNodes(flattenChildren(menuContent))
            let contentAttrs: [(key: String, value: String)] = [
                (key: "data-sparrow-floating", value: "bottom"),
                (key: "data-sparrow-floating-anchor", value: triggerId),
                (key: "data-sparrow-dismissable", value: dismissId),
                (key: "data-sparrow-roving", value: "vertical"),
                (key: "role", value: "menu")
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["dropdown-content"], extraAttrs: contentAttrs, children: menuNodes)
            allChildren.append(.element(contentEl))
        }

        var extraAttrs = modifierContext.allExtraAttributePairs
        extraAttrs.append((key: "data-sparrow-event", value: "contextmenu"))
        let classes = ["context-menu"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: extraAttrs, children: allChildren)
        return .element(el)
    }
}
