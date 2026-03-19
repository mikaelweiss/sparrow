/// Protocol for types that know how to render themselves to HTML.
/// This enables type-erased rendering of structural types like VStack, TupleView, etc.
protocol HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String
}

// MARK: - VStack

extension VStack: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        var classes = ["flex", "flex-col", alignment.cssClass] + modifierContext.cssClasses
        if spacing > 0 {
            classes.append("gap-\(spacingToken(spacing))")
        }
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
    }
}

// MARK: - HStack

extension HStack: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        var classes = ["flex", "flex-row", alignment.cssClass] + modifierContext.cssClasses
        if spacing > 0 {
            classes.append("gap-\(spacingToken(spacing))")
        }
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
    }
}

// MARK: - TupleView

extension TupleView: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let children = flattenTuple(value)
        return renderer.renderChildren(children, modifierContext: modifierContext)
    }
}

// MARK: - ModifiedView

extension ModifiedView: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let newContext = modifierContext.applying(modifier)
        return renderer.renderAnyErased(content, modifierContext: newContext)
    }
}

// MARK: - ConditionalView

extension ConditionalView: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        switch self {
        case .first(let view):
            return renderer.renderAnyErased(view, modifierContext: modifierContext)
        case .second(let view):
            return renderer.renderAnyErased(view, modifierContext: modifierContext)
        }
    }
}

// MARK: - Child flattening

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
