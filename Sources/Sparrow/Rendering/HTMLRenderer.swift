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
    /// Internally builds a VNode tree (stored on renderState.rootVNode for diffing)
    /// and serializes it to HTML.
    public func render(_ view: some View) -> String {
        let vnode = renderVNode(view)
        renderState.rootVNode = vnode
        return vnode.toHTML()
    }

    /// Allocate an element ID, using a custom ID from `.id()` modifier if set.
    /// Always advances the auto-counter for deterministic ID allocation.
    func resolveId(context: ModifierContext) -> String {
        let autoId = renderState.allocateId()
        return context.customId ?? autoId
    }

    // MARK: - VNode rendering

    /// Render a view to a virtual DOM tree. Used by SessionActor for diffing.
    public func renderVNode(_ view: some View) -> VNode {
        renderAnyVNode(view, modifierContext: ModifierContext())
    }

    func renderAnyVNode(_ view: some View, modifierContext: ModifierContext) -> VNode {
        if let result = renderKnownVNode(view, modifierContext: modifierContext) {
            return result
        }
        return renderAnyVNode(view.body, modifierContext: ModifierContext())
    }

    private func renderKnownVNode(_ view: some View, modifierContext: ModifierContext) -> VNode? {
        if let text = view as? Text { return renderTextVNode(text, context: modifierContext) }
        if let button = view as? Button { return renderButtonVNode(button, context: modifierContext) }
        if let link = view as? Link { return renderLinkVNode(link, context: modifierContext) }
        if view is Spacer { return renderSpacerVNode(context: modifierContext) }
        if view is Divider { return renderDividerVNode(context: modifierContext) }
        if let md = view as? Markdown { return renderMarkdownVNode(md, context: modifierContext) }
        if let field = view as? TextField { return renderTextFieldVNode(field, context: modifierContext) }
        if let field = view as? SecureField { return renderSecureFieldVNode(field, context: modifierContext) }
        if let editor = view as? TextEditor { return renderTextEditorVNode(editor, context: modifierContext) }
        if let toggle = view as? Toggle { return renderToggleVNode(toggle, context: modifierContext) }
        if let picker = view as? Picker { return renderPickerVNode(picker, context: modifierContext) }
        if let slider = view as? Slider { return renderSliderVNode(slider, context: modifierContext) }
        if let dp = view as? DatePicker { return renderDatePickerVNode(dp, context: modifierContext) }
        if let img = view as? Image { return renderImageVNode(img, context: modifierContext) }
        if let icon = view as? Icon { return renderIconVNode(icon, context: modifierContext) }
        if let navLink = view as? NavigationLink { return renderNavigationLinkVNode(navLink, context: modifierContext) }
        if let pv = view as? ProgressView { return renderProgressViewVNode(pv, context: modifierContext) }
        if view is Content { return renderContentVNode(context: modifierContext) }
        if view is EmptyView { return .fragment([]) }
        if let renderable = view as? any VNodeRenderable {
            return renderable.renderVNode(with: self, modifierContext: modifierContext)
        }
        return nil
    }

    func renderAnyErasedVNode(_ view: any View, modifierContext: ModifierContext) -> VNode {
        func doRender<V: View>(_ v: V) -> VNode {
            renderAnyVNode(v, modifierContext: modifierContext)
        }
        return doRender(view)
    }

    func renderChildrenVNodes(_ views: [any View], modifierContext: ModifierContext = ModifierContext()) -> [VNode] {
        views.map { renderAnyErasedVNode($0, modifierContext: modifierContext) }
    }

    // MARK: - VNode primitive renderers

    private func renderTextVNode(_ text: Text, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let tag = context.htmlTag ?? "p"
        let el = ElementNode.build(
            tag: tag, id: id,
            classes: context.cssClasses,
            styles: context.inlineStyles,
            extraAttrs: context.htmlAttributePairs,
            children: textSpanVNodes(text.spans)
        )
        return .element(el)
    }

    private func textSpanVNodes(_ spans: [TextSpan]) -> [VNode] {
        if spans.count == 1 && !spans[0].hasInlineStyles {
            return [.text(escapeHTML(spans[0].content))]
        }
        return spans.map { spanVNode($0) }
    }

    private func spanVNode(_ span: TextSpan) -> VNode {
        if !span.hasInlineStyles {
            return .text(escapeHTML(span.content))
        }
        // Build nested inline elements: innermost is the text
        var node: VNode = .text(escapeHTML(span.content))
        if span.isStrikethrough {
            let id = renderState.allocateId()
            node = .element(ElementNode.build(tag: "del", id: id, children: [node]))
        }
        if span.isUnderline {
            let id = renderState.allocateId()
            node = .element(ElementNode.build(tag: "span", id: id, classes: ["underline"], children: [node]))
        }
        if let weight = span.fontWeight {
            let id = renderState.allocateId()
            if weight == .bold {
                node = .element(ElementNode.build(tag: "strong", id: id, children: [node]))
            } else {
                node = .element(ElementNode.build(tag: "span", id: id, classes: [weight.cssClass], children: [node]))
            }
        }
        if span.isItalic {
            let id = renderState.allocateId()
            node = .element(ElementNode.build(tag: "em", id: id, children: [node]))
        }
        return node
    }

    private func renderButtonVNode(_ button: Button, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: button.action)
        let classes = ["btn", button.variant.cssClass, button.size.cssClass] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [("data-sparrow-event", "click")]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "button", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs,
            children: [.text(escapeHTML(button.label))]
        )
        return .element(el)
    }

    private func renderLinkVNode(_ link: Link, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["link"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [
            ("href", escapeHTML(link.url)),
            ("target", "_blank"),
            ("rel", "noopener noreferrer"),
        ]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "a", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs,
            children: [.text(escapeHTML(link.label))]
        )
        return .element(el)
    }

    private func renderSpacerVNode(context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["flex-grow"] + context.cssClasses
        return .element(ElementNode.build(tag: "div", id: id, classes: classes))
    }

    private func renderDividerVNode(context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["divider"] + context.cssClasses
        return .element(ElementNode.build(tag: "hr", id: id, classes: classes))
    }

    private func renderMarkdownVNode(_ md: Markdown, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["markdown"] + context.cssClasses
        let html = MarkdownParser.html(from: md.content)
        // Markdown renders to raw HTML — wrap as a text node (already escaped by the parser)
        let el = ElementNode.build(
            tag: "div", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: context.htmlAttributePairs,
            children: [.text(html)]
        )
        return .element(el)
    }

    private func renderTextFieldVNode(_ field: TextField, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let binding = field.text
        renderState.registerValueHandler(id: id) { newValue in binding.wrappedValue = newValue }
        let classes = ["input"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [
            ("type", "text"),
            ("placeholder", escapeHTML(field.placeholder)),
            ("value", escapeHTML(binding.wrappedValue)),
            ("data-sparrow-event", "input"),
            ("data-sparrow-debounce", "300"),
        ]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "input", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs
        )
        return .element(el)
    }

    private func renderSecureFieldVNode(_ field: SecureField, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let binding = field.text
        renderState.registerValueHandler(id: id) { newValue in binding.wrappedValue = newValue }
        let classes = ["input"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [
            ("type", "password"),
            ("placeholder", escapeHTML(field.placeholder)),
            ("value", escapeHTML(binding.wrappedValue)),
            ("data-sparrow-event", "input"),
            ("data-sparrow-debounce", "300"),
        ]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "input", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs
        )
        return .element(el)
    }

    private func renderTextEditorVNode(_ editor: TextEditor, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let binding = editor.text
        renderState.registerValueHandler(id: id) { newValue in binding.wrappedValue = newValue }
        let classes = ["textarea"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [
            ("data-sparrow-event", "input"),
            ("data-sparrow-debounce", "300"),
        ]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "textarea", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs,
            children: [.text(escapeHTML(binding.wrappedValue))]
        )
        return .element(el)
    }

    private func renderToggleVNode(_ toggle: Toggle, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let binding = toggle.isOn
        renderState.registerValueHandler(id: id) { newValue in binding.wrappedValue = (newValue == "true") }
        let classes = ["toggle"] + context.cssClasses
        // Toggle is a <label> wrapping an <input type="checkbox">
        var inputAttrs = OrderedAttributes([
            ("id", id),
            ("type", "checkbox"),
            ("data-sparrow-event", "change"),
        ])
        if binding.wrappedValue { inputAttrs["checked"] = "" }
        let inputNode = VNode.element(ElementNode(tag: "input", id: id, attributes: inputAttrs))
        var labelAttrs = OrderedAttributes()
        if !classes.isEmpty { labelAttrs["class"] = classes.joined(separator: " ") }
        if !context.inlineStyles.isEmpty { labelAttrs["style"] = formatStyles(context.inlineStyles) }
        for (key, value) in context.htmlAttributePairs { labelAttrs[key] = value }
        let labelId = renderState.allocateId()
        labelAttrs["id"] = labelId
        let labelNode = ElementNode(tag: "label", id: labelId, attributes: labelAttrs, children: [
            inputNode, .text(" " + escapeHTML(toggle.label)),
        ])
        return .element(labelNode)
    }

    private func renderPickerVNode(_ picker: Picker, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let binding = picker.selection
        renderState.registerValueHandler(id: id) { newValue in binding.wrappedValue = newValue }
        let selected = binding.wrappedValue
        let classes = ["picker"] + context.cssClasses
        let optionNodes: [VNode] = picker.options.map { opt in
            let optId = renderState.allocateId()
            var attrs = OrderedAttributes([("id", optId), ("value", escapeHTML(opt.value))])
            if opt.value == selected { attrs["selected"] = "" }
            return .element(ElementNode(tag: "option", id: optId, attributes: attrs, children: [.text(escapeHTML(opt.label))]))
        }
        var extraAttrs: [(key: String, value: String)] = [
            ("aria-label", escapeHTML(picker.label)),
            ("data-sparrow-event", "change"),
        ]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "select", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs,
            children: optionNodes
        )
        return .element(el)
    }

    private func renderSliderVNode(_ slider: Slider, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let binding = slider.value
        renderState.registerValueHandler(id: id) { newValue in
            if let d = Double(newValue) { binding.wrappedValue = d }
        }
        let classes = ["slider"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [
            ("type", "range"),
            ("min", "\(slider.range.lowerBound)"),
            ("max", "\(slider.range.upperBound)"),
            ("step", "\(slider.step)"),
            ("value", "\(binding.wrappedValue)"),
            ("data-sparrow-event", "input"),
        ]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "input", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs
        )
        return .element(el)
    }

    private func renderDatePickerVNode(_ dp: DatePicker, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let binding = dp.selection
        renderState.registerValueHandler(id: id) { newValue in binding.wrappedValue = newValue }
        let classes = ["input"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [
            ("type", "date"),
            ("aria-label", escapeHTML(dp.label)),
            ("value", escapeHTML(binding.wrappedValue)),
            ("data-sparrow-event", "change"),
        ]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "input", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs
        )
        return .element(el)
    }

    private func renderImageVNode(_ img: Image, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["img"] + context.cssClasses
        let src: String
        switch img.source {
        case .asset(let name): src = "/assets/\(escapeHTML(name))"
        case .url(let url): src = escapeHTML(url)
        }
        var extraAttrs: [(key: String, value: String)] = [
            ("src", src),
            ("alt", escapeHTML(img.alt)),
        ]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "img", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs
        )
        return .element(el)
    }

    private func renderIconVNode(_ icon: Icon, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["icon"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [("data-icon", escapeHTML(icon.systemName))]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "span", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs
        )
        return .element(el)
    }

    private func renderNavigationLinkVNode(_ navLink: NavigationLink, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let isCurrent = navLink.current || renderState.currentPath == navLink.destination
        var classes = ["nav-link"] + context.cssClasses
        if isCurrent { classes.append("nav-link-current") }
        var extraAttrs: [(key: String, value: String)] = [
            ("href", escapeHTML(navLink.destination)),
            ("data-sparrow-nav", ""),
        ]
        if isCurrent { extraAttrs.append(("aria-current", "page")) }
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "a", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs,
            children: [.text(escapeHTML(navLink.label))]
        )
        return .element(el)
    }

    private func renderProgressViewVNode(_ pv: ProgressView, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["progress"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = []
        if let value = pv.value {
            extraAttrs.append(("value", "\(value)"))
            extraAttrs.append(("max", "\(pv.total)"))
        }
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "progress", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs
        )
        return .element(el)
    }

    private func renderContentVNode(context: ModifierContext) -> VNode {
        let contentChildren = renderState.contentSlotVNode.map { [$0] } ?? []
        let el = ElementNode.build(
            tag: "div", id: "sparrow-content",
            classes: context.cssClasses,
            styles: context.inlineStyles,
            children: contentChildren
        )
        return .element(el)
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

func formatHTMLAttributes(_ attrs: [String: String]) -> String {
    guard !attrs.isEmpty else { return "" }
    return attrs.sorted(by: { $0.key < $1.key })
        .map { " \($0.key)=\"\(escapeHTML($0.value))\"" }
        .joined()
}
