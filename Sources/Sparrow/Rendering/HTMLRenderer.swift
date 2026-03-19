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
        // Label
        if let label = view as? Label {
            return renderLabel(label, context: modifierContext)
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
        // Alert
        if let alert = view as? Alert {
            return renderAlert(alert, context: modifierContext)
        }
        // Toast
        if let toast = view as? Toast {
            return renderToast(toast, context: modifierContext)
        }
        // Badge
        if let badge = view as? Badge {
            return renderBadge(badge, context: modifierContext)
        }
        // ProgressView
        if let pv = view as? ProgressView {
            return renderProgressView(pv, context: modifierContext)
        }
        // Spinner
        if view is Spinner {
            return renderSpinner(context: modifierContext)
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

    private func renderLabel(_ label: Label, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["label"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escapedTitle = escapeHTML(label.title)
        let escapedIcon = escapeHTML(label.icon)
        return "        <span id=\"\(id)\"\(classAttr)\(styleAttr)><span class=\"label-icon\">\(escapedIcon)</span> \(escapedTitle)</span>"
    }

    private func renderMarkdown(_ md: Markdown, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["markdown"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let html = MarkdownParser.html(from: md.content)
        return "        <div id=\"\(id)\"\(classAttr)\(styleAttr)>\(html)</div>"
    }

    private func renderTextField(_ field: TextField, context: ModifierContext) -> String {
        let id = renderState.allocateId()
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
        let id = renderState.allocateId()
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
        let id = renderState.allocateId()
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
        let id = renderState.allocateId()
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
        let id = renderState.allocateId()
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
        let id = renderState.allocateId()
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
        let id = renderState.allocateId()
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
        let id = renderState.allocateId()
        let classes = ["img"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let src: String
        switch img.source {
        case .asset(let name): src = "/assets/\(escapeHTML(name))"
        case .url(let url): src = escapeHTML(url)
        }
        return "        <img id=\"\(id)\" src=\"\(src)\"\(classAttr)\(styleAttr)>"
    }

    private func renderIcon(_ icon: Icon, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["icon"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(icon.systemName)
        return "        <span id=\"\(id)\" data-icon=\"\(escaped)\"\(classAttr)\(styleAttr)></span>"
    }

    private func renderNavigationLink(_ navLink: NavigationLink, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["nav-link"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(navLink.label)
        let dest = escapeHTML(navLink.destination)
        return "        <a id=\"\(id)\" href=\"\(dest)\" data-sparrow-nav\(classAttr)\(styleAttr)>\(escaped)</a>"
    }

    private func renderAlert(_ alert: Alert, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["alert"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let titleHTML = escapeHTML(alert.title)
        let messageHTML = alert.message.isEmpty ? "" : "\n            <p class=\"alert-message\">\(escapeHTML(alert.message))</p>"
        return "        <div id=\"\(id)\" role=\"alert\"\(classAttr)\(styleAttr)>\n            <p class=\"alert-title\">\(titleHTML)</p>\(messageHTML)\n        </div>"
    }

    private func renderToast(_ toast: Toast, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let styleName: String
        switch toast.style {
        case .info: styleName = "info"
        case .success: styleName = "success"
        case .warning: styleName = "warning"
        case .error: styleName = "error"
        }
        let classes = ["toast", "toast-\(styleName)"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(toast.message)
        return "        <div id=\"\(id)\"\(classAttr)\(styleAttr)>\(escaped)</div>"
    }

    private func renderBadge(_ badge: Badge, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let styleName: String
        switch badge.style {
        case .default: styleName = "default"
        case .success: styleName = "success"
        case .warning: styleName = "warning"
        case .error: styleName = "error"
        case .info: styleName = "info"
        }
        let classes = ["badge", "badge-\(styleName)"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(badge.text)
        return "        <span id=\"\(id)\"\(classAttr)\(styleAttr)>\(escaped)</span>"
    }

    private func renderProgressView(_ pv: ProgressView, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["progress"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        if let value = pv.value {
            return "        <progress id=\"\(id)\" value=\"\(value)\" max=\"\(pv.total)\"\(classAttr)\(styleAttr)></progress>"
        } else {
            return "        <progress id=\"\(id)\"\(classAttr)\(styleAttr)></progress>"
        }
    }

    private func renderSpinner(context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["spinner"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        return "        <div id=\"\(id)\"\(classAttr)\(styleAttr)></div>"
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
