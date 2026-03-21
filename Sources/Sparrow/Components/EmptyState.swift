/// Empty state placeholder matching ShadCN Empty.
public struct EmptyState<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: Never { fatalError() }
}

extension EmptyState: Sendable where Content: Sendable {}

extension EmptyState: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["empty-state"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: childNodes)
        return .element(el)
    }
}
