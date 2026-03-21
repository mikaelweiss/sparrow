/// Button group matching ShadCN ButtonGroup.
public struct ButtonGroup<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: Never { fatalError() }
}

extension ButtonGroup: Sendable where Content: Sendable {}

extension ButtonGroup: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["btn-group"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: childNodes)
        return .element(el)
    }
}
