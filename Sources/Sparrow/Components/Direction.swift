/// Direction wrapper matching ShadCN Direction (RTL/LTR).
/// Stays VNodeRenderable because there's no modifier to set the `dir` HTML attribute.
public struct Direction<Content: View>: View {
    let dir: TextDirection
    let content: Content
    public init(_ dir: TextDirection, @ViewBuilder content: () -> Content) {
        self.dir = dir
        self.content = content()
    }
    public var body: Never { fatalError() }
}

public enum TextDirection: String, Sendable {
    case ltr, rtl
}

extension Direction: Sendable where Content: Sendable {}

extension Direction: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        var extraAttrs = modifierContext.allExtraAttributePairs
        extraAttrs.append((key: "dir", value: dir.rawValue))
        let el = ElementNode.build(tag: "div", id: id, classes: modifierContext.cssClasses, styles: modifierContext.inlineStyles, extraAttrs: extraAttrs, children: childNodes)
        return .element(el)
    }
}
