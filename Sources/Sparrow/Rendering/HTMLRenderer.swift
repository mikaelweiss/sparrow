/// Renders a View tree into an HTML string.
public struct HTMLRenderer: Sendable {
    public init() {}

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
        let classes = context.cssClasses
        let styles = context.inlineStyles
        let classAttr = classes.isEmpty ? "" : " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = styles.isEmpty ? "" : " style=\"\(formatStyles(styles))\""

        // Determine HTML tag based on font modifier
        let tag = context.htmlTag ?? "p"
        let escaped = escapeHTML(text.content)
        return "        <\(tag)\(classAttr)\(styleAttr)>\(escaped)</\(tag)>"
    }

    private func renderSpacer(context: ModifierContext) -> String {
        let classes = ["flex-grow"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        return "        <div\(classAttr)></div>"
    }

    private func renderDivider(context: ModifierContext) -> String {
        let classes = ["divider"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        return "        <hr\(classAttr)>"
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
