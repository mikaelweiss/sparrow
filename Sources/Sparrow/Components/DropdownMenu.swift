/// DropdownMenu matching ShadCN DropdownMenu.
public struct DropdownMenu<Trigger: View, MenuContent: View>: View {
    let isOpen: Bool
    let side: FloatingSide
    let onToggle: @Sendable () -> Void
    let onDismiss: @Sendable () -> Void
    let trigger: Trigger
    let menuContent: MenuContent
    public init(isOpen: Bool, side: FloatingSide = .bottom, onToggle: @escaping @Sendable () -> Void, onDismiss: @escaping @Sendable () -> Void, @ViewBuilder trigger: () -> Trigger, @ViewBuilder content: () -> MenuContent) {
        self.isOpen = isOpen
        self.side = side
        self.onToggle = onToggle
        self.onDismiss = onDismiss
        self.trigger = trigger()
        self.menuContent = content()
    }
    public var body: Never { fatalError() }
}

public struct DropdownMenuItem: PrimitiveView, Sendable {
    public let label: String
    public let action: @Sendable () -> Void
    public init(_ label: String, action: @escaping @Sendable () -> Void) {
        self.label = label
        self.action = action
    }
}

public struct DropdownMenuSeparator: PrimitiveView, Sendable {
    public init() {}
}

public struct DropdownMenuLabel: PrimitiveView, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }
}

public struct DropdownMenuGroup<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: Never { fatalError() }
}

extension DropdownMenu: Sendable where Trigger: Sendable, MenuContent: Sendable {}
extension DropdownMenuGroup: Sendable where Content: Sendable {}

extension DropdownMenu: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let triggerId = renderer.renderState.allocateId()
        renderer.renderState.registerHandler(id: triggerId, handler: onToggle)
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())

        var allChildren: [VNode] = [triggerNode]

        if isOpen {
            let contentId = renderer.renderState.allocateId()
            renderer.renderState.registerHandler(id: contentId, handler: onDismiss)
            let menuNodes = renderer.renderChildrenVNodes(flattenChildren(menuContent))
            let contentAttrs: [(key: String, value: String)] = [
                (key: "data-sparrow-floating", value: side.rawValue),
                (key: "data-sparrow-floating-anchor", value: triggerId),
                (key: "data-sparrow-dismissable", value: triggerId),
                (key: "data-sparrow-roving", value: "vertical"),
                (key: "role", value: "menu")
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["dropdown-content"], extraAttrs: contentAttrs, children: menuNodes)
            allChildren.append(.element(contentEl))
        }

        let classes = ["dropdown"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }
}

extension DropdownMenuGroup: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children, modifierContext: modifierContext)
        return .fragment(childNodes)
    }
}
