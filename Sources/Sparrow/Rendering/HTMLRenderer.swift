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
        // SegmentedControl
        if let seg = view as? SegmentedControl {
            return renderSegmentedControl(seg, context: modifierContext)
        }
        // RadioGroup
        if let radio = view as? RadioGroup {
            return renderRadioGroup(radio, context: modifierContext)
        }
        // Checkbox
        if let checkbox = view as? Checkbox {
            return renderCheckbox(checkbox, context: modifierContext)
        }
        // Combobox
        if let combo = view as? Combobox {
            return renderCombobox(combo, context: modifierContext)
        }
        // ColorPicker
        if let cp = view as? ColorPicker {
            return renderColorPicker(cp, context: modifierContext)
        }
        // SearchField
        if let sf = view as? SearchField {
            return renderSearchField(sf, context: modifierContext)
        }
        // Skeleton
        if let sk = view as? Skeleton {
            return renderSkeleton(sk, context: modifierContext)
        }
        // Gauge
        if let gauge = view as? Gauge {
            return renderGauge(gauge, context: modifierContext)
        }
        // Accordion
        if let acc = view as? Accordion {
            return renderAccordion(acc, context: modifierContext)
        }
        // Pagination
        if let pg = view as? Pagination {
            return renderPagination(pg, context: modifierContext)
        }
        // DataTable
        if let dt = view as? DataTable {
            return renderDataTable(dt, context: modifierContext)
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

    /// Text renders as the semantic HTML tag from its font modifier (h1 for .largeTitle,
    /// h2 for .title, etc.) or falls back to `<p>` if no font modifier is applied.
    /// Supports inline styling via TextSpans for concatenated text.
    private func renderText(_ text: Text, context: ModifierContext) -> String {
        let id = renderState.allocateId()
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
        let id = renderState.allocateId()
        renderState.registerHandler(id: id, handler: button.action)

        let classes = ["btn", button.variant.cssClass, button.size.cssClass] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
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


    private func renderMarkdown(_ md: Markdown, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["markdown"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let html = MarkdownParser.html(from: md.content)
        return "        <div id=\"\(id)\"\(classAttr)\(styleAttr)>\(html)</div>"
    }

    /// Input fields use `data-sparrow-debounce="300"` — the client JS debounces input
    /// events by 300ms before sending to the server to avoid flooding the WebSocket.
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
        var classes = ["nav-link"] + context.cssClasses
        if navLink.current {
            classes.append("nav-link-current")
        }
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let ariaAttr = navLink.current ? " aria-current=\"page\"" : ""
        let escaped = escapeHTML(navLink.label)
        let dest = escapeHTML(navLink.destination)
        return "        <a id=\"\(id)\" href=\"\(dest)\" data-sparrow-nav\(classAttr)\(styleAttr)\(ariaAttr)>\(escaped)</a>"
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



    private func renderSegmentedControl(_ seg: SegmentedControl, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["segmented"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let buttons = seg.options.map { opt in
            let segId = renderState.allocateId()
            let isSelected = opt.value == seg.selection
            let selectedCls = isSelected ? " segmented-btn-active" : ""
            let ariaSelected = isSelected ? " aria-selected=\"true\"" : " aria-selected=\"false\""
            let tabindex = isSelected ? " tabindex=\"0\"" : " tabindex=\"-1\""
            let escaped = escapeHTML(opt.label)
            return "            <button id=\"\(segId)\" class=\"segmented-btn\(selectedCls)\" role=\"tab\"\(ariaSelected)\(tabindex) data-sparrow-roving-item data-sparrow-event=\"click\" data-value=\"\(escapeHTML(opt.value))\">\(escaped)</button>"
        }.joined(separator: "\n")
        return """
                <div id="\(id)" role="tablist" data-sparrow-roving="horizontal"\(classAttr)\(styleAttr)>
        \(buttons)
                </div>
        """
    }

    private func renderRadioGroup(_ radio: RadioGroup, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["radio-group"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let groupName = "radio_\(id)"
        let options = radio.options.map { opt in
            let optId = renderState.allocateId()
            let checked = opt.value == radio.selection ? " checked" : ""
            let escaped = escapeHTML(opt.label)
            return "            <label class=\"radio-option\" data-sparrow-roving-item><input id=\"\(optId)\" type=\"radio\" name=\"\(groupName)\" value=\"\(escapeHTML(opt.value))\"\(checked) data-sparrow-event=\"change\"> \(escaped)</label>"
        }.joined(separator: "\n")
        let legend = escapeHTML(radio.label)
        return """
                <fieldset id="\(id)"\(classAttr)\(styleAttr) role="radiogroup" data-sparrow-roving="vertical">
                    <legend class="radio-legend">\(legend)</legend>
        \(options)
                </fieldset>
        """
    }

    private func renderCheckbox(_ checkbox: Checkbox, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["checkbox"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let checked = checkbox.isChecked ? " checked" : ""
        let escaped = escapeHTML(checkbox.label)
        return "        <label id=\"\(id)\"\(classAttr)\(styleAttr)><input type=\"checkbox\"\(checked) data-sparrow-event=\"change\"> \(escaped)</label>"
    }

    private func renderCombobox(_ combo: Combobox, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let listId = "dl_\(id)"
        let classes = ["input", "combobox"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let options = combo.options.map { opt in
            "            <option value=\"\(escapeHTML(opt.value))\">\(escapeHTML(opt.label))</option>"
        }.joined(separator: "\n")
        return """
                <input id="\(id)" type="text" list="\(listId)" placeholder="\(escapeHTML(combo.label))" value="\(escapeHTML(combo.text))"\(classAttr)\(styleAttr) data-sparrow-event="input" data-sparrow-debounce="300">
                <datalist id="\(listId)">
        \(options)
                </datalist>
        """
    }

    private func renderColorPicker(_ cp: ColorPicker, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["color-picker"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let escaped = escapeHTML(cp.label)
        return "        <label id=\"\(id)\"\(classAttr)\(styleAttr)>\(escaped) <input type=\"color\" value=\"\(escapeHTML(cp.selection))\" data-sparrow-event=\"change\"></label>"
    }

    private func renderSearchField(_ sf: SearchField, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["input", "search-field"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        return "        <input id=\"\(id)\" type=\"search\" placeholder=\"\(escapeHTML(sf.placeholder))\" value=\"\(escapeHTML(sf.text))\"\(classAttr)\(styleAttr) data-sparrow-event=\"input\" data-sparrow-debounce=\"300\">"
    }

    private func renderSkeleton(_ sk: Skeleton, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        switch sk.shape {
        case .rectangle:
            let classes = ["skeleton", "skeleton-rect"] + context.cssClasses
            let classAttr = " class=\"\(classes.joined(separator: " "))\""
            let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
            return "        <div id=\"\(id)\"\(classAttr)\(styleAttr)></div>"
        case .circle:
            let classes = ["skeleton", "skeleton-circle"] + context.cssClasses
            let classAttr = " class=\"\(classes.joined(separator: " "))\""
            let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
            return "        <div id=\"\(id)\"\(classAttr)\(styleAttr)></div>"
        case .text(let lines):
            let classes = ["skeleton-text"] + context.cssClasses
            let classAttr = " class=\"\(classes.joined(separator: " "))\""
            let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
            let lineHTML = (0..<lines).map { i in
                let lineId = i == 0 ? id : renderState.allocateId()
                let widthClass = i == lines - 1 ? " skeleton-line-short" : ""
                return "            <div id=\"\(lineId)\" class=\"skeleton skeleton-line\(widthClass)\"></div>"
            }.joined(separator: "\n")
            return """
                    <div\(classAttr)\(styleAttr)>
            \(lineHTML)
                    </div>
            """
        }
    }


    private func renderGauge(_ gauge: Gauge, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["gauge"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let label = gauge.label.isEmpty ? "" : " aria-label=\"\(escapeHTML(gauge.label))\""
        return "        <meter id=\"\(id)\" min=\"\(gauge.range.lowerBound)\" max=\"\(gauge.range.upperBound)\" value=\"\(gauge.value)\"\(label)\(classAttr)\(styleAttr)></meter>"
    }

    private func renderAccordion(_ acc: Accordion, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["accordion"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""
        let nameAttr = acc.allowMultiple ? "" : " name=\"acc_\(id)\""
        let items = acc.items.map { item in
            let itemId = renderState.allocateId()
            let open = item.isExpanded ? " open" : ""
            return """
                        <details id="\(itemId)" class="accordion-item"\(nameAttr)\(open)>
                            <summary class="accordion-header">\(escapeHTML(item.label))</summary>
                            <div class="accordion-content">\(escapeHTML(item.content))</div>
                        </details>
            """
        }.joined(separator: "\n")
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
        \(items)
                </div>
        """
    }


    private func renderPagination(_ pg: Pagination, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["pagination"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""

        let prevId = renderState.allocateId()
        let nextId = renderState.allocateId()
        let prevDisabled = pg.currentPage <= 1 ? " disabled" : ""
        let nextDisabled = pg.currentPage >= pg.totalPages ? " disabled" : ""

        // Page number buttons (desktop only)
        var pageButtons = ""
        for page in 1...pg.totalPages {
            let pageId = renderState.allocateId()
            let activeCls = page == pg.currentPage ? " pagination-btn-active" : ""
            pageButtons += "            <button id=\"\(pageId)\" class=\"pagination-btn pagination-page\(activeCls)\" data-sparrow-event=\"click\">\(page)</button>\n"
        }

        return """
                <nav id="\(id)" aria-label="Pagination"\(classAttr)\(styleAttr)>
                    <button id="\(prevId)" class="pagination-btn pagination-prev" data-sparrow-event="click"\(prevDisabled)>Previous</button>
        \(pageButtons)            <button id="\(nextId)" class="pagination-btn pagination-next" data-sparrow-event="click"\(nextDisabled)>Next</button>
                </nav>
        """
    }

    private func renderDataTable(_ dt: DataTable, context: ModifierContext) -> String {
        let id = renderState.allocateId()
        let classes = ["data-table-wrapper"] + context.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = context.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(context.inlineStyles))\""

        let headers = dt.columns.map { col in
            let alignCls: String
            switch col.alignment {
            case .leading: alignCls = "text-start"
            case .center: alignCls = "text-center"
            case .trailing: alignCls = "text-end"
            }
            return "                <th class=\"\(alignCls)\">\(escapeHTML(col.header))</th>"
        }.joined(separator: "\n")

        let rows = dt.rows.map { row in
            let cells = row.enumerated().map { i, cell in
                let alignCls: String
                if i < dt.columns.count {
                    switch dt.columns[i].alignment {
                    case .leading: alignCls = "text-start"
                    case .center: alignCls = "text-center"
                    case .trailing: alignCls = "text-end"
                    }
                } else {
                    alignCls = "text-start"
                }
                return "                <td class=\"\(alignCls)\">\(escapeHTML(cell))</td>"
            }.joined(separator: "\n")
            return "            <tr>\n\(cells)\n            </tr>"
        }.joined(separator: "\n")

        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
                    <table class="data-table">
                        <thead>
                            <tr>
        \(headers)
                            </tr>
                        </thead>
                        <tbody>
        \(rows)
                        </tbody>
                    </table>
                </div>
        """
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
