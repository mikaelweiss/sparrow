/// Carousel matching ShadCN Carousel.
public struct Carousel<Content: View>: View {
    let orientation: CarouselOrientation
    let content: Content
    public init(orientation: CarouselOrientation = .horizontal, @ViewBuilder content: () -> Content) {
        self.orientation = orientation
        self.content = content()
    }

    public var body: Never { fatalError() }
}

public struct CarouselContent<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: Never { fatalError() }
}

public struct CarouselItem<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: Never { fatalError() }
}

/// Carousel navigation — PrimitiveView because it registers a click handler.
public struct CarouselPrevious: PrimitiveView, Sendable {
    public let action: @Sendable () -> Void
    public init(action: @escaping @Sendable () -> Void) { self.action = action }
}

public struct CarouselNext: PrimitiveView, Sendable {
    public let action: @Sendable () -> Void
    public init(action: @escaping @Sendable () -> Void) { self.action = action }
}

public enum CarouselOrientation: Sendable { case horizontal, vertical }

extension Carousel: Sendable where Content: Sendable {}
extension CarouselContent: Sendable where Content: Sendable {}
extension CarouselItem: Sendable where Content: Sendable {}

// MARK: - VNodeRenderable

extension Carousel: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        var classes = ["carousel"] + modifierContext.cssClasses
        switch orientation {
        case .horizontal: classes.append("carousel-horizontal")
        case .vertical: classes.append("carousel-vertical")
        }
        var extraAttrs = modifierContext.allExtraAttributePairs
        extraAttrs.append((key: "role", value: "region"))
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: extraAttrs, children: childNodes)
        return .element(el)
    }
}

extension CarouselContent: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["carousel-content"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: childNodes)
        return .element(el)
    }
}

extension CarouselItem: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["carousel-item"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: childNodes)
        return .element(el)
    }
}
