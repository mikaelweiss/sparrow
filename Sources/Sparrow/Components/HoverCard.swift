/// CSS-only hover card matching ShadCN HoverCard.
public struct HoverCard<Trigger: View, Content: View>: View {
    let side: FloatingSide
    let trigger: Trigger
    let hoverContent: Content
    public init(side: FloatingSide = .bottom, @ViewBuilder trigger: () -> Trigger, @ViewBuilder content: () -> Content) {
        self.side = side
        self.trigger = trigger()
        self.hoverContent = content()
    }
    public var body: Never { fatalError() }
}

extension HoverCard: Sendable where Trigger: Sendable, Content: Sendable {}

extension HoverCard: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let triggerId = renderer.renderState.allocateId()
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())

        let contentId = renderer.renderState.allocateId()
        let contentNodes = renderer.renderChildrenVNodes(flattenChildren(hoverContent))
        let contentAttrs: [(key: String, value: String)] = [
            (key: "data-sparrow-floating", value: side.rawValue),
            (key: "data-sparrow-floating-anchor", value: triggerId)
        ]
        let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["hover-card-content"], extraAttrs: contentAttrs, children: contentNodes)

        let classes = ["hover-card"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: [triggerNode, .element(contentEl)])
        return .element(el)
    }
}
