/// Bottom drawer matching ShadCN Drawer (vaul).
public struct Drawer<Trigger: View, DrawerBody: View>: View {
    let isOpen: Bool
    let onDismiss: @Sendable () -> Void
    let trigger: Trigger
    let drawerBody: DrawerBody
    public init(isOpen: Bool, onDismiss: @escaping @Sendable () -> Void, @ViewBuilder trigger: () -> Trigger, @ViewBuilder content: () -> DrawerBody) {
        self.isOpen = isOpen
        self.onDismiss = onDismiss
        self.trigger = trigger()
        self.drawerBody = content()
    }
    public var body: Never { fatalError() }
}

public struct DrawerHeader<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: Never { fatalError() }
}

public struct DrawerFooter<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: Never { fatalError() }
}

public struct DrawerTitle: PrimitiveView, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }
}

public struct DrawerDescription: PrimitiveView, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }
}

extension Drawer: Sendable where Trigger: Sendable, DrawerBody: Sendable {}
extension DrawerHeader: Sendable where Content: Sendable {}
extension DrawerFooter: Sendable where Content: Sendable {}

extension Drawer: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let triggerId = renderer.renderState.allocateId()
        renderer.renderState.registerHandler(id: triggerId, handler: onDismiss)
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())
        var allChildren: [VNode] = [triggerNode]

        if isOpen {
            let overlayId = renderer.renderState.allocateId()
            let overlay = ElementNode.build(tag: "div", id: overlayId, classes: ["drawer-overlay"])
            allChildren.append(.element(overlay))

            let contentId = renderer.renderState.allocateId()
            let bodyNodes = renderer.renderChildrenVNodes(flattenChildren(drawerBody))
            // Drag handle indicator
            let handleId = renderer.renderState.allocateId()
            let handle = ElementNode.build(tag: "div", id: handleId, classes: ["drawer-handle"])
            var contentChildren: [VNode] = [.element(handle)]
            contentChildren.append(contentsOf: bodyNodes)
            let contentAttrs: [(key: String, value: String)] = [
                (key: "role", value: "dialog"),
                (key: "data-sparrow-focus-trap", value: ""),
                (key: "data-sparrow-dismissable", value: triggerId)
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["drawer-content"], extraAttrs: contentAttrs, children: contentChildren)
            allChildren.append(.element(contentEl))
        }

        let el = ElementNode.build(tag: "div", id: id, classes: modifierContext.cssClasses, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }
}

extension DrawerHeader: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["drawer-header"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: childNodes)
        return .element(el)
    }
}

extension DrawerFooter: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["drawer-footer"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: childNodes)
        return .element(el)
    }
}
