/// Alert Dialog matching ShadCN AlertDialog.
/// Unlike Dialog, AlertDialog does NOT dismiss on outside click and requires explicit action.
public struct AlertDialog<Trigger: View, DialogBody: View>: View {
    let isOpen: Bool
    let onOpenChange: @Sendable (Bool) -> Void
    let trigger: Trigger
    let dialogBody: DialogBody
    public init(isOpen: Bool, onOpenChange: @escaping @Sendable (Bool) -> Void, @ViewBuilder trigger: () -> Trigger, @ViewBuilder content: () -> DialogBody) {
        self.isOpen = isOpen
        self.onOpenChange = onOpenChange
        self.trigger = trigger()
        self.dialogBody = content()
    }
    public var body: Never { fatalError() }
}

public struct AlertDialogAction: PrimitiveView, Sendable {
    public let label: String
    public let action: @Sendable () -> Void
    public init(_ label: String, action: @escaping @Sendable () -> Void) {
        self.label = label
        self.action = action
    }
}

public struct AlertDialogCancel: PrimitiveView, Sendable {
    public let label: String
    public let action: @Sendable () -> Void
    public init(_ label: String = "Cancel", action: @escaping @Sendable () -> Void) {
        self.label = label
        self.action = action
    }
}

extension AlertDialog: Sendable where Trigger: Sendable, DialogBody: Sendable {}

extension AlertDialog: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let triggerId = renderer.renderState.allocateId()
        renderer.renderState.registerHandler(id: triggerId) { [onOpenChange] in onOpenChange(true) }
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())
        var allChildren: [VNode] = [triggerNode]

        if isOpen {
            let overlayId = renderer.renderState.allocateId()
            let overlay = ElementNode.build(tag: "div", id: overlayId, classes: ["alert-dialog-overlay"])
            allChildren.append(.element(overlay))

            let contentId = renderer.renderState.allocateId()
            let bodyNodes = renderer.renderChildrenVNodes(flattenChildren(dialogBody))
            // No data-sparrow-dismissable — alert dialogs require explicit action
            let contentAttrs: [(key: String, value: String)] = [
                (key: "role", value: "alertdialog"),
                (key: "aria-modal", value: "true"),
                (key: "data-sparrow-focus-trap", value: "")
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["alert-dialog-content"], extraAttrs: contentAttrs, children: bodyNodes)
            allChildren.append(.element(contentEl))
        }

        let el = ElementNode.build(tag: "div", id: id, classes: modifierContext.cssClasses, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }
}
