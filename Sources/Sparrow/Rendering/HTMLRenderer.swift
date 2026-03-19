/// Renders a View tree into an HTML string.
/// Each render pass creates a fresh RenderState that allocates element IDs
/// and collects event handlers for interactive elements.
public struct HTMLRenderer: Sendable {
    let renderState: RenderState

    public init() {
        self.renderState = RenderState()
    }

    /// Render a view to an HTML fragment.
    public func render(_ view: some View) -> String {
        renderAny(view, modifierContext: ModifierContext())
    }

    // MARK: - Internal rendering

    private func renderAny(_ view: some View, modifierContext: ModifierContext) -> String {
        // Check for known primitive/structural types first, then fall back to resolving body.
        if let result = renderKnown(view, modifierContext: modifierContext) {
            return result
        }
        // User-defined view: resolve its body
        return renderAny(view.body, modifierContext: ModifierContext())
    }

    /// Try to render known types. Returns nil if the type isn't recognized as a primitive.
    private func renderKnown(_ view: some View, modifierContext: ModifierContext) -> String? {
        // Text
        if let text = view as? Text {
            return renderText(text, context: modifierContext)
        }
        // Button
        if let button = view as? Button {
            return renderButton(button, context: modifierContext)
        }
        // Link
        if let link = view as? Link {
            return renderLink(link, context: modifierContext)
        }
        // Spacer
        if view is Spacer {
            return renderSpacer(context: modifierContext)
        }
        // Divider
        if view is Divider {
            return renderDivider(context: modifierContext)
        }
        // EmptyView
        if view is EmptyView {
            return ""
        }
        // Try structural types via protocol
        if let renderable = view as? any HTMLRenderable {
            return renderable.renderHTML(with: self, modifierContext: modifierContext)
        }
        return nil
    }

    // MARK: - Primitive renderers

    private func renderText(_ text: Text, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = context.cssClasses
        let styles = context.inlineStyles
        let idAttr = " id=\"\(id)\""
        let classAttr = classes.isEmpty ? "" : " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = styles.isEmpty ? "" : " style=\"\(formatStyles(styles))\""

        // Determine HTML tag based on font modifier
        let tag = context.htmlTag ?? "p"
        let escaped = escapeHTML(text.content)
        return "        <\(tag)\(idAttr)\(classAttr)\(styleAttr)>\(escaped)</\(tag)>"
    }

    private func renderButton(_ button: Button, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        renderState.registerHandler(id: id, handler: button.action)

        let classes = ["btn"] + context.cssClasses
        let classAttr = classes.isEmpty ? "" : " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(button.label)
        return "        <button id=\"\(id)\"\(classAttr) data-sparrow-event=\"click\"\(styleAttr)>\(escaped)</button>"
    }

    private func renderLink(_ link: Link, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["link"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(link.label)
        let href = escapeHTML(link.url)
        return "        <a id=\"\(id)\" href=\"\(href)\" target=\"_blank\" rel=\"noopener noreferrer\"\(classAttr)\(styleAttr)>\(escaped)</a>"
    }

    private func renderSpacer(context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["flex-grow"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        return "        <div id=\"\(id)\"\(classAttr)></div>"
    }

    private func renderDivider(context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["divider"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        return "        <hr id=\"\(id)\"\(classAttr)>"
    }

    // MARK: - Helpers (internal, used by HTMLRenderable conformances)

    func renderChildren(_ views: [any View], modifierContext: ModifierContext = ModifierContext()) -> String {
        views.map { renderAnyErased($0, modifierContext: modifierContext) }.joined(separator: "\n")
    }

    func renderAnyErased(_ view: any View, modifierContext: ModifierContext) -> String {
        func doRender<V: View>(_ v: V) -> String {
            renderAny(v, modifierContext: modifierContext)
        }
        return doRender(view)
    }
}

// MARK: - Utilities

func escapeHTML(_ string: String) -> String {
    string
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}

func formatStyles(_ styles: [String: String]) -> String {
    styles.map { "\($0.key): \($0.value)" }.joined(separator: "; ")
}
