/// Menubar matching ShadCN Menubar.
public struct Menubar<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: Never { fatalError() }
}

public struct MenubarMenu<Trigger: View, MenuContent: View>: View {
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

public struct MenubarTrigger: PrimitiveView, Sendable {
    public let label: String
    public init(_ label: String) { self.label = label }
}

public struct MenubarItem: PrimitiveView, Sendable {
    public let label: String
    public let shortcut: String?
    public let action: @Sendable () -> Void
    public init(_ label: String, shortcut: String? = nil, action: @escaping @Sendable () -> Void) {
        self.label = label
        self.shortcut = shortcut
        self.action = action
    }
}

public struct MenubarSeparator: PrimitiveView, Sendable {
    public init() {}
}

extension Menubar: Sendable where Content: Sendable {}
extension MenubarMenu: Sendable where Trigger: Sendable, MenuContent: Sendable {}

extension Menubar: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["menubar"] + modifierContext.cssClasses
        var extraAttrs = modifierContext.allExtraAttributePairs
        extraAttrs.append((key: "role", value: "menubar"))
        extraAttrs.append((key: "data-sparrow-roving", value: "horizontal"))
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: extraAttrs, children: childNodes)
        return .element(el)
    }
}

extension MenubarMenu: VNodeRenderable {
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
                (key: "data-sparrow-dismissable", value: triggerId),
                (key: "data-sparrow-roving", value: "vertical"),
                (key: "role", value: "menu")
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["menubar-content"], extraAttrs: contentAttrs, children: menuNodes)
            allChildren.append(.element(contentEl))
        }

        let classes = ["menubar-menu"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }
}
