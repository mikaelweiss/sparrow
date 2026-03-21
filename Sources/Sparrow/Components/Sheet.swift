/// Sheet (side panel) component matching ShadCN Sheet.
public struct Sheet<Trigger: View, SheetBody: View>: View {
    let isOpen: Bool
    let side: SheetSide
    let onDismiss: @Sendable () -> Void
    let trigger: Trigger
    let sheetBody: SheetBody
    public init(isOpen: Bool, side: SheetSide = .right, onDismiss: @escaping @Sendable () -> Void, @ViewBuilder trigger: () -> Trigger, @ViewBuilder content: () -> SheetBody) {
        self.isOpen = isOpen
        self.side = side
        self.onDismiss = onDismiss
        self.trigger = trigger()
        self.sheetBody = content()
    }
    public var body: Never { fatalError() }
}

public enum SheetSide: Sendable {
    case top, right, bottom, left

    var cssClass: String {
        switch self {
        case .top: "sheet-top"
        case .right: "sheet-right"
        case .bottom: "sheet-bottom"
        case .left: "sheet-left"
        }
    }
}

extension Sheet: Sendable where Trigger: Sendable, SheetBody: Sendable {}

extension Sheet: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        var allChildren: [VNode] = []
        let triggerId = renderer.renderState.allocateId()
        renderer.renderState.registerHandler(id: triggerId, handler: onDismiss)
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())
        allChildren.append(triggerNode)

        if isOpen {
            let overlayId = renderer.renderState.allocateId()
            let overlay = ElementNode.build(tag: "div", id: overlayId, classes: ["dialog-overlay"])
            allChildren.append(.element(overlay))

            let contentId = renderer.renderState.allocateId()
            let bodyNodes = renderer.renderChildrenVNodes(flattenChildren(sheetBody))
            let contentAttrs: [(key: String, value: String)] = [
                (key: "role", value: "dialog"),
                (key: "data-sparrow-focus-trap", value: ""),
                (key: "data-sparrow-dismissable", value: triggerId)
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["sheet-content", side.cssClass], extraAttrs: contentAttrs, children: bodyNodes)
            allChildren.append(.element(contentEl))
        }

        let el = ElementNode.build(tag: "div", id: id, classes: modifierContext.cssClasses, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }
}
