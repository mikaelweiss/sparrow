/// Form field wrapper matching ShadCN Field (label + control + description + error).
public struct Field<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: Never { fatalError() }
}

/// Field description text.
public struct FieldDescription: View, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.body)
            .foreground(.mutedForeground)
    }
}

/// Field error text — PrimitiveView for role="alert" attribute.
public struct FieldError: PrimitiveView, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }
}

extension Field: Sendable where Content: Sendable {}

extension Field: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["field"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: childNodes)
        return .element(el)
    }
}
