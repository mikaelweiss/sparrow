/// Popover matching ShadCN Popover.
public struct PopoverMenu<Trigger: View, Content: View>: View {
    let isOpen: Bool
    let side: FloatingSide
    let onToggle: @Sendable () -> Void
    let onDismiss: @Sendable () -> Void
    let trigger: Trigger
    let popoverContent: Content
    public init(isOpen: Bool, side: FloatingSide = .bottom, onToggle: @escaping @Sendable () -> Void, onDismiss: @escaping @Sendable () -> Void, @ViewBuilder trigger: () -> Trigger, @ViewBuilder content: () -> Content) {
        self.isOpen = isOpen
        self.side = side
        self.onToggle = onToggle
        self.onDismiss = onDismiss
        self.trigger = trigger()
        self.popoverContent = content()
    }
    public var body: Never { fatalError() }
}

extension PopoverMenu: Sendable where Trigger: Sendable, Content: Sendable {}

extension PopoverMenu: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let triggerId = renderer.renderState.allocateId()
        renderer.renderState.registerHandler(id: triggerId, handler: onToggle)
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())

        var allChildren: [VNode] = [triggerNode]

        if isOpen {
            let contentId = renderer.renderState.allocateId()
            let contentNodes = renderer.renderChildrenVNodes(flattenChildren(popoverContent))
            let contentAttrs: [(key: String, value: String)] = [
                (key: "data-sparrow-floating", value: side.rawValue),
                (key: "data-sparrow-floating-anchor", value: triggerId),
                (key: "data-sparrow-dismissable", value: triggerId),
                (key: "role", value: "dialog")
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["popover-content"], extraAttrs: contentAttrs, children: contentNodes)
            allChildren.append(.element(contentEl))
        }

        let classes = ["popover-wrapper"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }
}
