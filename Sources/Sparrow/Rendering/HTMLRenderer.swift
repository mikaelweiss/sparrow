import SparrowMarkdown

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

    /// Main dispatch: tries known primitives/structurals first. If unrecognized,
    /// assumes it's a user-defined view and recurses into its `body`.
    /// Modifier context resets on body resolution — modifiers only apply to the
    /// view they're attached to, not to its children.
    private func renderAny(_ view: some View, modifierContext: ModifierContext) -> String {
        if let result = renderKnown(view, modifierContext: modifierContext) {
            return result
        }
        return renderAny(view.body, modifierContext: ModifierContext())
    }

    /// Try to render known types. Returns nil if the type isn't recognized,
    /// which causes `renderAny` to fall through to resolving the view's `body`.
    /// Primitive views are matched here by type; structural containers (VStack, etc.)
    /// fall through to the `HTMLRenderable` protocol check at the bottom.
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
        // Markdown
        if let md = view as? Markdown {
            return renderMarkdown(md, context: modifierContext)
        }
        // TextField
        if let field = view as? TextField {
            return renderTextField(field, context: modifierContext)
        }
        // SecureField
        if let field = view as? SecureField {
            return renderSecureField(field, context: modifierContext)
        }
        // TextEditor
        if let editor = view as? TextEditor {
            return renderTextEditor(editor, context: modifierContext)
        }
        // Toggle
        if let toggle = view as? Toggle {
            return renderToggle(toggle, context: modifierContext)
        }
        // Picker
        if let picker = view as? Picker {
            return renderPicker(picker, context: modifierContext)
        }
        // Slider
        if let slider = view as? Slider {
            return renderSlider(slider, context: modifierContext)
        }
        // DatePicker
        if let dp = view as? DatePicker {
            return renderDatePicker(dp, context: modifierContext)
        }
        // Image
        if let img = view as? Image {
            return renderImage(img, context: modifierContext)
        }
        // Icon
        if let icon = view as? Icon {
            return renderIcon(icon, context: modifierContext)
        }
        // NavigationLink
        if let navLink = view as? NavigationLink {
            return renderNavigationLink(navLink, context: modifierContext)
        }
        // ProgressView
        if let pv = view as? ProgressView {
            return renderProgressView(pv, context: modifierContext)
        }
        // Content (Layout placeholder)
        if view is Content {
            return renderContent(context: modifierContext)
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

    /// Allocate an element ID, using a custom ID from `.id()` modifier if set.
    /// Always advances the auto-counter for deterministic ID allocation.
    func resolveId(context: ModifierContext) -> String {
        let autoId = renderState.allocateId()
        return context.customId ?? autoId
    }

    // MARK: - Primitive renderers

    /// Text renders as the semantic HTML tag from its font modifier (h1 for .largeTitle,
    /// h2 for .title, etc.) or falls back to `<p>` if no font modifier is applied.
    /// Supports inline styling via TextSpans for concatenated text.
    private func renderText(_ text: Text, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let classes = context.cssClasses
        let styles = context.inlineStyles
        let idAttr = " id=\"\(id)\""
        let classAttr = classes.isEmpty ? "" : " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = styles.isEmpty ? "" : " style=\"\(formatStyles(styles))\""

        let tag = context.htmlTag ?? "p"
        let inner = renderTextSpans(text.spans)
        return "        <\(tag)\(idAttr)\(classAttr)\(styleAttr)>\(inner)</\(tag)>"
    }

    private func renderTextSpans(_ spans: [TextSpan]) -> String {
        if spans.count == 1 && !spans[0].hasInlineStyles {
            return escapeHTML(spans[0].content)
        }
        return spans.map { renderSingleSpan($0) }.joined()
    }

    private func renderSingleSpan(_ span: TextSpan) -> String {
        var html = escapeHTML(span.content)
        if !span.hasInlineStyles { return html }

        // Semantic tags for common styles
        if span.isStrikethrough { html = "<del>\(html)</del>" }
        if span.isUnderline { html = "<span class=\"underline\">\(html)</span>" }
        if let weight = span.fontWeight {
            if weight == .bold {
                html = "<strong>\(html)</strong>"
            } else {
                html = "<span class=\"\(weight.cssClass)\">\(html)</span>"
            }
        }
        if span.isItalic { html = "<em>\(html)</em>" }
        return html
    }

    private func renderButton(_ button: Button, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: button.action)

        let classes = ["btn", button.variant.cssClass, button.size.cssClass] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(button.label)
        return "        <button id=\"\(id)\"\(classAttr) data-sparrow-event=\"click\"\(styleAttr)>\(escaped)</button>"
    }

    private func renderLink(_ link: Link, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let classes = ["link"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(link.label)
        let href = escapeHTML(link.url)
        return "        <a id=\"\(id)\" href=\"\(href)\" target=\"_blank\" rel=\"noopener noreferrer\"\(classAttr)\(styleAttr)>\(escaped)</a>"
    }

    private func renderSpacer(context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let classes = ["flex-grow"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        return "        <div id=\"\(id)\"\(classAttr)></div>"
    }

    private func renderDivider(context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let classes = ["divider"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        return "        <hr id=\"\(id)\"\(classAttr)>"
    }


    private func renderMarkdown(_ md: Markdown, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let classes = ["markdown"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let html = MarkdownParser.html(from: md.content)
        return "        <div id=\"\(id)\"\(classAttr)\(styleAttr)>\(html)</div>"
    }

    /// Input fields use `data-sparrow-debounce="300"` — the client JS debounces input
    /// events by 300ms before sending to the server to avoid flooding the WebSocket.
    private func renderTextField(_ field: TextField, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let binding = field.text
        renderState.registerValueHandler(id: id) { newValue in
            binding.wrappedValue = newValue
        }
        let classes = ["input"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let placeholder = escapeHTML(field.placeholder)
        let value = escapeHTML(binding.wrappedValue)
        return "        <input id=\"\(id)\" type=\"text\" placeholder=\"\(placeholder)\" value=\"\(value)\"\(classAttr) data-sparrow-event=\"input\" data-sparrow-debounce=\"300\"\(styleAttr)>"
    }

    private func renderSecureField(_ field: SecureField, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let binding = field.text
        renderState.registerValueHandler(id: id) { newValue in
            binding.wrappedValue = newValue
        }
        let classes = ["input"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let placeholder = escapeHTML(field.placeholder)
        let value = escapeHTML(binding.wrappedValue)
        return "        <input id=\"\(id)\" type=\"password\" placeholder=\"\(placeholder)\" value=\"\(value)\"\(classAttr) data-sparrow-event=\"input\" data-sparrow-debounce=\"300\"\(styleAttr)>"
    }

    private func renderTextEditor(_ editor: TextEditor, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let binding = editor.text
        renderState.registerValueHandler(id: id) { newValue in
            binding.wrappedValue = newValue
        }
        let classes = ["textarea"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(binding.wrappedValue)
        return "        <textarea id=\"\(id)\"\(classAttr) data-sparrow-event=\"input\" data-sparrow-debounce=\"300\"\(styleAttr)>\(escaped)</textarea>"
    }

    private func renderToggle(_ toggle: Toggle, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let binding = toggle.isOn
        renderState.registerValueHandler(id: id) { newValue in
            binding.wrappedValue = (newValue == "true")
        }
        let classes = ["toggle"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let checked = binding.wrappedValue ? " checked" : ""
        let escaped = escapeHTML(toggle.label)
        return "        <label\(classAttr)\(styleAttr)><input id=\"\(id)\" type=\"checkbox\"\(checked) data-sparrow-event=\"change\"> \(escaped)</label>"
    }

    private func renderPicker(_ picker: Picker, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let binding = picker.selection
        renderState.registerValueHandler(id: id) { newValue in
            binding.wrappedValue = newValue
        }
        let selected = binding.wrappedValue
        let classes = ["picker"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let options = picker.options.map { opt in
            let selectedAttr = opt.value == selected ? " selected" : ""
            return "            <option value=\"\(escapeHTML(opt.value))\"\(selectedAttr)>\(escapeHTML(opt.label))</option>"
        }.joined(separator: "\n")
        return """
                <select id="\(id)" aria-label="\(escapeHTML(picker.label))"\(classAttr) data-sparrow-event="change"\(styleAttr)>
        \(options)
                </select>
        """
    }

    private func renderSlider(_ slider: Slider, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let binding = slider.value
        renderState.registerValueHandler(id: id) { newValue in
            if let d = Double(newValue) {
                binding.wrappedValue = d
            }
        }
        let classes = ["slider"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        return "        <input id=\"\(id)\" type=\"range\" min=\"\(slider.range.lowerBound)\" max=\"\(slider.range.upperBound)\" step=\"\(slider.step)\" value=\"\(binding.wrappedValue)\"\(classAttr) data-sparrow-event=\"input\"\(styleAttr)>"
    }

    private func renderDatePicker(_ dp: DatePicker, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let binding = dp.selection
        renderState.registerValueHandler(id: id) { newValue in
            binding.wrappedValue = newValue
        }
        let classes = ["input"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let value = escapeHTML(binding.wrappedValue)
        return "        <input id=\"\(id)\" type=\"date\" aria-label=\"\(escapeHTML(dp.label))\" value=\"\(value)\"\(classAttr) data-sparrow-event=\"change\"\(styleAttr)>"
    }

    private func renderImage(_ img: Image, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let classes = ["img"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let src: String
        switch img.source {
        case .asset(let name): src = "/assets/\(escapeHTML(name))"
        case .url(let url): src = escapeHTML(url)
        }
        let alt = escapeHTML(img.alt)
        return "        <img id=\"\(id)\" src=\"\(src)\" alt=\"\(alt)\"\(classAttr)\(styleAttr)>"
    }

    private func renderIcon(_ icon: Icon, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let classes = ["icon"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(icon.systemName)
        return "        <span id=\"\(id)\" data-icon=\"\(escaped)\"\(classAttr)\(styleAttr)></span>"
    }

    private func renderNavigationLink(_ navLink: NavigationLink, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let isCurrent = navLink.current || renderState.currentPath == navLink.destination
        var classes = ["nav-link"] + context.cssClasses
        if isCurrent {
            classes.append("nav-link-current")
        }
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let ariaAttr = isCurrent ? " aria-current=\"page\"" : ""
        let escaped = escapeHTML(navLink.label)
        let dest = escapeHTML(navLink.destination)
        return "        <a id=\"\(id)\" href=\"\(dest)\" data-sparrow-nav\(classAttr)\(styleAttr)\(ariaAttr)>\(escaped)</a>"
    }




    private func renderProgressView(_ pv: ProgressView, context: ModifierContext) -> String {
        let id = resolveId(context: context)
        let classes = ["progress"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        if let value = pv.value {
            return "        <progress id=\"\(id)\" value=\"\(value)\" max=\"\(pv.total)\"\(classAttr)\(styleAttr)></progress>"
        } else {
            return "        <progress id=\"\(id)\"\(classAttr)\(styleAttr)></progress>"
        }
    }




    /// Layout Content() placeholder — emits pre-rendered page HTML wrapped in a
    /// targetable container so same-layout navigation can swap just this area.
    private func renderContent(context: ModifierContext) -> String {
        let contentHTML = renderState.contentSlot ?? ""
        let classes = context.cssClasses
        let classAttr = classes.isEmpty ? "" : " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        return "        <div id=\"sparrow-content\"\(classAttr)\(styleAttr)>\n\(contentHTML)\n        </div>"
    }

    // MARK: - Helpers (internal, used by HTMLRenderable conformances)

    func renderChildren(_ views: [any View], modifierContext: ModifierContext = ModifierContext()) -> String {
        views.map { renderAnyErased($0, modifierContext: modifierContext) }.joined(separator: "\n")
    }

    /// Render an existential `any View`. The local generic function opens the
    /// existential so we can call the generic `renderAny` with a concrete type.
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
