/// Adopted by structural view types (VStack, TupleView, ModifiedView, etc.) so the
/// renderer can dispatch to them via a single protocol check instead of enumerating
/// every container type in `renderKnown`. Primitive views (Text, Button, etc.) are
/// handled directly in HTMLRenderer and don't need this.
protocol HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String
}

// MARK: - VStack

extension VStack: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        var classes = ["flex", "flex-col", alignment.cssClass] + modifierContext.cssClasses
        if spacing > 0 {
            classes.append("gap-\(spacingToken(spacing))")
        }
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
    }
}

// MARK: - HStack

extension HStack: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        var classes = ["flex", "flex-row", alignment.cssClass] + modifierContext.cssClasses
        if spacing > 0 {
            classes.append("gap-\(spacingToken(spacing))")
        }
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
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
        if modifier.createsLayer {
            let innerHTML = renderer.renderAnyErased(content, modifierContext: modifierContext)
            let id = renderer.renderState.allocateId()
            let classes = modifier.cssClasses
            let styles = modifier.inlineStyles
            let classAttr = classes.isEmpty ? "" : " class=\"\(classes.joined(separator: " "))\""
            let styleAttr = styles.isEmpty ? "" : " style=\"\(formatStyles(styles))\""
            return "        <div id=\"\(id)\"\(classAttr)\(styleAttr)>\n\(innerHTML)\n        </div>"
        } else {
            let newContext = modifierContext.applying(modifier)
            return renderer.renderAnyErased(content, modifierContext: newContext)
        }
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

// MARK: - ZStack

extension ZStack: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["zstack", alignment.justifyCss, alignment.alignCss] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
    }
}

// MARK: - ScrollView

extension ScrollView: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        var classes = ["scroll"] + modifierContext.cssClasses
        switch axis {
        case .vertical: classes.append("scroll-y")
        case .horizontal: classes.append("scroll-x")
        case .both: classes.append("scroll-both")
        }
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
    }
}

// MARK: - Grid

extension Grid: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        var classes = ["grid"] + modifierContext.cssClasses
        classes.append("grid-cols-\(columns)")
        if spacing > 0 {
            classes.append("gap-\(spacingToken(spacing))")
        }
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
    }
}

// MARK: - List

extension List: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = children.map { child in
            "        <li>\(renderer.renderAnyErased(child, modifierContext: ModifierContext()))</li>"
        }.joined(separator: "\n")
        let tag = ordered ? "ol" : "ul"
        let classes = ["list"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <\(tag) id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </\(tag)>
        """
    }
}

// MARK: - Form

extension Form: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["form"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <form id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </form>
        """
    }
}

// MARK: - Section

extension Section: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["section"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        let headerHTML = header.map { "        <h3 class=\"section-header\">\(escapeHTML($0))</h3>\n" } ?? ""
        return """
                <section id="\(id)"\(classAttr)\(styleAttr)>
        \(headerHTML)\(childrenHTML)
                </section>
        """
    }
}

// MARK: - ForEach

extension ForEach: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        data.map { element in
            renderer.renderAnyErased(content(element), modifierContext: modifierContext)
        }.joined(separator: "\n")
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
