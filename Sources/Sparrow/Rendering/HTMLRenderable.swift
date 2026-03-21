/// Extract child views from a ViewBuilder result, handling TupleView nesting.
func flattenChildren(_ view: some View) -> [any View] {
    if let renderable = view as? any TupleFlattening {
        return renderable.flattenedChildren()
    }
    return [view]
}

protocol TupleFlattening {
    func flattenedChildren() -> [any View]
}

extension TupleView: TupleFlattening {
    func flattenedChildren() -> [any View] {
        flattenTuple(value)
    }
}

/// Use Mirror to extract views from a tuple (works for any arity).
func flattenTuple(_ value: Any) -> [any View] {
    let mirror = Mirror(reflecting: value)
    if mirror.children.isEmpty {
        // Single value, not actually a tuple
        if let view = value as? any View {
            return [view]
        }
        return []
    }
    return mirror.children.compactMap { $0.value as? any View }
}

// MARK: - VNodeRenderable

/// Adopted by structural view types (VStack, TupleView, ModifiedView, etc.) so the
/// renderer can dispatch to them via a single protocol check instead of enumerating
/// every container type in `renderKnownVNode`. Primitive views (Text, Button, etc.) are
/// handled directly in HTMLRenderer and don't need this.
protocol VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode
}

extension VStack: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        var classes = ["flex", "flex-col", alignment.cssClass] + modifierContext.cssClasses
        if spacing > 0 { classes.append("gap-\(spacingToken(spacing))") }
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.htmlAttributePairs, children: childNodes)
        return .element(el)
    }
}

extension HStack: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        var classes = ["flex", "flex-row", alignment.cssClass] + modifierContext.cssClasses
        if spacing > 0 { classes.append("gap-\(spacingToken(spacing))") }
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.htmlAttributePairs, children: childNodes)
        return .element(el)
    }
}

extension TupleView: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let children = flattenTuple(value)
        let nodes = renderer.renderChildrenVNodes(children, modifierContext: modifierContext)
        return .fragment(nodes)
    }
}

extension ConditionalView: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        switch self {
        case .first(let view): return renderer.renderView(view, modifierContext: modifierContext)
        case .second(let view): return renderer.renderView(view, modifierContext: modifierContext)
        }
    }
}

extension ZStack: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["zstack", alignment.justifyCss, alignment.alignCss] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.htmlAttributePairs, children: childNodes)
        return .element(el)
    }
}

extension ScrollView: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        var classes = ["scroll"] + modifierContext.cssClasses
        switch axis {
        case .vertical: classes.append("scroll-y")
        case .horizontal: classes.append("scroll-x")
        case .both: classes.append("scroll-both")
        }
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.htmlAttributePairs, children: childNodes)
        return .element(el)
    }
}

extension Grid: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        var classes = ["grid"] + modifierContext.cssClasses
        classes.append("grid-cols-\(columns)")
        if spacing > 0 { classes.append("gap-\(spacingToken(spacing))") }
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.htmlAttributePairs, children: childNodes)
        return .element(el)
    }
}

extension List: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let liNodes: [VNode] = children.map { child in
            let liId = renderer.renderState.allocateId()
            let inner = renderer.renderView(child, modifierContext: ModifierContext())
            return .element(ElementNode.build(tag: "li", id: liId, children: [inner]))
        }
        let tag = ordered ? "ol" : "ul"
        let classes = ["list"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: tag, id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.htmlAttributePairs, children: liNodes)
        return .element(el)
    }
}

extension Form: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["form"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "form", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.htmlAttributePairs, children: childNodes)
        return .element(el)
    }
}

extension Section: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        let classes = ["section"] + modifierContext.cssClasses
        var allChildren: [VNode] = []
        if let h = header {
            let headerId = renderer.renderState.allocateId()
            let headerEl = ElementNode.build(
                tag: "h3", id: headerId,
                classes: ["section-header"],
                children: [.text(escapeHTML(h))]
            )
            allChildren.append(.element(headerEl))
        }
        allChildren.append(contentsOf: childNodes)
        let el = ElementNode.build(tag: "section", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.htmlAttributePairs, children: allChildren)
        return .element(el)
    }
}

extension ForEach: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let nodes = data.map { element in
            renderer.renderView(content(element), modifierContext: modifierContext)
        }
        return .fragment(nodes)
    }
}
