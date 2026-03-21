/// Resizable panels matching ShadCN Resizable.
public struct ResizablePanelGroup<Content: View>: View {
    let direction: ResizableDirection
    let content: Content
    public init(direction: ResizableDirection = .horizontal, @ViewBuilder content: () -> Content) {
        self.direction = direction
        self.content = content()
    }
    public var body: Never { fatalError() }
}

public struct ResizablePanel<Content: View>: View {
    let defaultSize: Double?
    let minSize: Double?
    let maxSize: Double?
    let content: Content
    public init(defaultSize: Double? = nil, minSize: Double? = nil, maxSize: Double? = nil, @ViewBuilder content: () -> Content) {
        self.defaultSize = defaultSize
        self.minSize = minSize
        self.maxSize = maxSize
        self.content = content()
    }
    public var body: Never { fatalError() }
}

public struct ResizableHandle: PrimitiveView, Sendable {
    public let withHandle: Bool
    public init(withHandle: Bool = false) { self.withHandle = withHandle }
}

public enum ResizableDirection: String, Sendable { case horizontal, vertical }

extension ResizablePanelGroup: Sendable where Content: Sendable {}
extension ResizablePanel: Sendable where Content: Sendable {}

extension ResizablePanelGroup: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let dirClass = direction == .horizontal ? "resizable-horizontal" : "resizable-vertical"
        let classes = ["resizable-group", dirClass] + modifierContext.cssClasses
        var extraAttrs = modifierContext.allExtraAttributePairs
        extraAttrs.append((key: "data-panel-group", value: ""))
        extraAttrs.append((key: "data-panel-group-direction", value: direction.rawValue))
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: extraAttrs, children: childNodes)
        return .element(el)
    }
}

extension ResizablePanel: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["resizable-panel"] + modifierContext.cssClasses
        var styles = modifierContext.inlineStyles
        if let size = defaultSize { styles["flex"] = "\(size) 1 0%" }
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: styles, extraAttrs: modifierContext.allExtraAttributePairs, children: childNodes)
        return .element(el)
    }
}
