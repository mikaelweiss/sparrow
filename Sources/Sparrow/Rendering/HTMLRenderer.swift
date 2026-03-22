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
        renderView(view, modifierContext: ModifierContext())
    }

    /// Main render entry point — uses existential dispatch to avoid monomorphizing
    /// for huge body types (which would cause stack overflows from large stack frames).
    func renderView(_ view: any View, modifierContext: ModifierContext) -> VNode {
        // ModifiedView chains: unwrap iteratively
        if let modified = view as? any ModifiedViewUnwrapping {
            return renderModifiedViewChain(modified, modifierContext: modifierContext)
        }
        // Primitive views and structural containers
        if let result = renderKnownView(view, modifierContext: modifierContext) {
            return result
        }
        // User-defined composite view: render its body (type-erased, stays on heap)
        return renderView(view.body, modifierContext: ModifierContext())
    }

    private func renderKnownView(_ view: any View, modifierContext: ModifierContext) -> VNode? {
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
        if let checkbox = view as? Checkbox { return renderCheckboxVNode(checkbox, context: modifierContext) }
        if let radio = view as? RadioGroup { return renderRadioGroupVNode(radio, context: modifierContext) }
        if let th = view as? TableHead { return renderTableHeadVNode(th, context: modifierContext) }
        if let caption = view as? TableCaption { return renderTableCaptionVNode(caption, context: modifierContext) }
        if let picker = view as? Picker { return renderPickerVNode(picker, context: modifierContext) }
        if let slider = view as? Slider { return renderSliderVNode(slider, context: modifierContext) }
        if let dp = view as? DatePicker { return renderDatePickerVNode(dp, context: modifierContext) }
        if let img = view as? Image { return renderImageVNode(img, context: modifierContext) }
        if let icon = view as? Icon { return renderIconVNode(icon, context: modifierContext) }
        if let navLink = view as? NavigationLink { return renderNavigationLinkVNode(navLink, context: modifierContext) }
        if let pv = view as? ProgressView { return renderProgressViewVNode(pv, context: modifierContext) }
        if let rive = view as? RiveAnimation { return renderRiveAnimationVNode(rive, context: modifierContext) }
        if let lottie = view as? LottieAnimation { return renderLottieAnimationVNode(lottie, context: modifierContext) }
        if let phaseAnim = view as? any _PhaseAnimatorRenderable { return renderPhaseAnimatorVNode(phaseAnim, context: modifierContext) }
        if let kfAnim = view as? any _KeyframeAnimatorRenderable { return renderKeyframeAnimatorVNode(kfAnim, context: modifierContext) }
        if view is Content { return renderContentVNode(context: modifierContext) }
        // Component PrimitiveViews
        if let v = view as? BreadcrumbLink { return renderBreadcrumbLinkVNode(v, context: modifierContext) }
        if let v = view as? BreadcrumbSeparator { return renderBreadcrumbSeparatorVNode(v, context: modifierContext) }
        if let v = view as? BreadcrumbPage { return renderBreadcrumbPageVNode(v, context: modifierContext) }
        if let v = view as? AvatarImage { return renderAvatarImageVNode(v, context: modifierContext) }
        if let v = view as? AvatarFallback { return renderAvatarFallbackVNode(v, context: modifierContext) }
        if let v = view as? Label { return renderLabelVNode(v, context: modifierContext) }
        if let v = view as? Skeleton { return renderSkeletonVNode(v, context: modifierContext) }
        if let v = view as? TabsTrigger { return renderTabsTriggerVNode(v, context: modifierContext) }
        if let v = view as? AccordionTrigger { return renderAccordionTriggerVNode(v, context: modifierContext) }
        if let v = view as? CollapsibleTrigger { return renderCollapsibleTriggerVNode(v, context: modifierContext) }
        if let v = view as? ToggleGroupItem { return renderToggleGroupItemVNode(v, context: modifierContext) }
        if let v = view as? ToggleButton { return renderToggleButtonVNode(v, context: modifierContext) }
        if let v = view as? DialogTitle { return renderDialogTitleVNode(v, context: modifierContext) }
        if let v = view as? DialogDescription { return renderDialogDescriptionVNode(v, context: modifierContext) }
        if let v = view as? DialogClose { return renderDialogCloseVNode(v, context: modifierContext) }
        if let v = view as? DropdownMenuItem { return renderDropdownMenuItemVNode(v, context: modifierContext) }
        if view is DropdownMenuSeparator { return renderDropdownMenuSeparatorVNode(context: modifierContext) }
        if let v = view as? DropdownMenuLabel { return renderDropdownMenuLabelVNode(v, context: modifierContext) }
        if let v = view as? SelectMenu { return renderSelectMenuVNode(v, context: modifierContext) }
        if let v = view as? CommandItem { return renderCommandItemVNode(v, context: modifierContext) }
        if view is CommandSeparator { return renderCommandSeparatorVNode(context: modifierContext) }
        if let v = view as? CommandEmpty { return renderCommandEmptyVNode(v, context: modifierContext) }
        if let v = view as? Pagination { return renderPaginationVNode(v, context: modifierContext) }
        if let v = view as? AlertDialogAction { return renderAlertDialogActionVNode(v, context: modifierContext) }
        if let v = view as? AlertDialogCancel { return renderAlertDialogCancelVNode(v, context: modifierContext) }
        if let v = view as? Spinner { return renderSpinnerVNode(v, context: modifierContext) }
        if let v = view as? Kbd { return renderKbdVNode(v, context: modifierContext) }
        if let v = view as? FieldDescription { return renderFieldDescriptionVNode(v, context: modifierContext) }
        if let v = view as? FieldError { return renderFieldErrorVNode(v, context: modifierContext) }
        if let v = view as? MenubarTrigger { return renderMenubarTriggerVNode(v, context: modifierContext) }
        if let v = view as? MenubarItem { return renderMenubarItemVNode(v, context: modifierContext) }
        if view is MenubarSeparator { return renderDropdownMenuSeparatorVNode(context: modifierContext) }
        if let v = view as? NavigationMenuTrigger { return renderNavMenuTriggerVNode(v, context: modifierContext) }
        if let v = view as? NavigationMenuLink { return renderNavMenuLinkVNode(v, context: modifierContext) }
        if let v = view as? Combobox { return renderComboboxVNode(v, context: modifierContext) }
        if let v = view as? InputOTP { return renderInputOTPVNode(v, context: modifierContext) }
        if let v = view as? ResizableHandle { return renderResizableHandleVNode(v, context: modifierContext) }
        if let v = view as? Calendar { return renderCalendarVNode(v, context: modifierContext) }
        if let v = view as? CarouselPrevious { return renderCarouselNavVNode(v.action, label: "\u{2039}", cssClass: "carousel-prev", context: modifierContext) }
        if let v = view as? CarouselNext { return renderCarouselNavVNode(v.action, label: "\u{203A}", cssClass: "carousel-next", context: modifierContext) }
        if let v = view as? any _DataTableRenderable { return v.renderDataTableVNode(with: self, modifierContext: modifierContext) }
        if let v = view as? SidebarGroupLabel { return renderSidebarGroupLabelVNode(v, context: modifierContext) }
        if let v = view as? SidebarMenuButton { return renderSidebarMenuButtonVNode(v, context: modifierContext) }
        if let v = view as? SidebarTrigger { return renderSidebarTriggerVNode(v, context: modifierContext) }
        if let v = view as? SidebarRail { return renderSidebarRailVNode(v, context: modifierContext) }
        if let v = view as? Toaster { return renderToasterVNode(v, context: modifierContext) }
        if let v = view as? DrawerTitle { return renderDrawerTitleVNode(v, context: modifierContext) }
        if let v = view as? DrawerDescription { return renderDrawerDescriptionVNode(v, context: modifierContext) }
        if let v = view as? TypographyH1 { return renderTypographyVNode(v.text, tag: "h1", cssClass: "typography-h1", context: modifierContext) }
        if let v = view as? TypographyH2 { return renderTypographyVNode(v.text, tag: "h2", cssClass: "typography-h2", context: modifierContext) }
        if let v = view as? TypographyH3 { return renderTypographyVNode(v.text, tag: "h3", cssClass: "typography-h3", context: modifierContext) }
        if let v = view as? TypographyH4 { return renderTypographyVNode(v.text, tag: "h4", cssClass: "typography-h4", context: modifierContext) }
        if let v = view as? TypographyP { return renderTypographyVNode(v.text, tag: "p", cssClass: "typography-p", context: modifierContext) }
        if let v = view as? TypographyLead { return renderTypographyVNode(v.text, tag: "p", cssClass: "typography-lead", context: modifierContext) }
        if let v = view as? TypographyLarge { return renderTypographyVNode(v.text, tag: "div", cssClass: "typography-large", context: modifierContext) }
        if let v = view as? TypographySmall { return renderTypographyVNode(v.text, tag: "small", cssClass: "typography-small", context: modifierContext) }
        if let v = view as? TypographyMuted { return renderTypographyVNode(v.text, tag: "p", cssClass: "typography-muted", context: modifierContext) }
        if let v = view as? TypographyInlineCode { return renderTypographyVNode(v.text, tag: "code", cssClass: "typography-code", context: modifierContext) }
        if let v = view as? TypographyBlockquote { return renderTypographyVNode(v.text, tag: "blockquote", cssClass: "typography-blockquote", context: modifierContext) }
        if view is EmptyView { return .fragment([]) }
        if let renderable = view as? any VNodeRenderable {
            return renderable.renderVNode(with: self, modifierContext: modifierContext)
        }
        return nil
    }

    /// Iteratively unwrap a ModifiedView chain and render it without recursion.
    /// Collects all modifiers, applies flat ones to the context, renders the leaf,
    /// then wraps with layer-creating modifier divs from inside out.
    func renderModifiedViewChain(_ outermost: any ModifiedViewUnwrapping, modifierContext: ModifierContext) -> VNode {
        // Collect modifiers from outer to inner
        var modifiers: [any ViewModifier] = []
        var leaf: any View = outermost.unwrappedContent
        modifiers.append(outermost.unwrappedModifier)

        while let modified = leaf as? any ModifiedViewUnwrapping {
            modifiers.append(modified.unwrappedModifier)
            leaf = modified.unwrappedContent
        }
        // modifiers[0] = outermost, modifiers.last = innermost

        // Separate flat modifiers (accumulate onto context) from layer modifiers (create wrapper divs).
        // Layer modifiers pass the context through unchanged; flat modifiers enrich it.
        var context = modifierContext

        struct LayerInfo {
            let modifier: any ViewModifier
            let id: String
        }
        var layers: [LayerInfo] = []

        for mod in modifiers {
            if mod.createsLayer {
                let id = resolveId(context: context)
                if let eventMod = mod as? any EventModifying {
                    eventMod.registerEvents(id: id, with: renderState)
                }
                layers.append(LayerInfo(modifier: mod, id: id))
            } else {
                context = context.applying(mod)
                if let eventMod = mod as? any EventModifying {
                    let id = resolveId(context: context)
                    eventMod.registerEvents(id: id, with: renderState)
                }
            }
        }

        // Render the leaf view with accumulated flat modifier context
        var node = renderView(leaf, modifierContext: context)

        // Emit scoped <style> for StateStyleModifiers (hover, focus, etc.)
        if !context.scopedStyles.isEmpty {
            let elementId = extractVNodeId(node)
            if let elementId, !elementId.isEmpty {
                let css = context.scopedStyles.map { $0.scopedCSS(for: elementId) }.joined(separator: " ")
                let styleNode = VNode.element(ElementNode.build(tag: "style", id: "", children: [.text(css)]))
                node = .fragment([styleNode, node])
            }
        }

        // Wrap with layer divs from innermost to outermost
        for layer in layers.reversed() {
            var extraAttrs = layer.modifier.htmlAttributes
                .sorted(by: { $0.key < $1.key })
                .map { (key: $0.key, value: $0.value) }
            // Include data attributes (e.g., animation/transition hooks)
            for (key, value) in layer.modifier.dataAttributes.sorted(by: { $0.key < $1.key }) {
                extraAttrs.append((key: key, value: value))
            }
            if let eventMod = layer.modifier as? any EventModifying {
                for (key, value) in eventMod.eventAttributes {
                    extraAttrs.append((key: key, value: value))
                }
            }
            let el = ElementNode.build(
                tag: "div", id: layer.id,
                classes: layer.modifier.cssClasses,
                styles: layer.modifier.inlineStyles,
                extraAttrs: extraAttrs,
                children: [node]
            )
            node = .element(el)
        }

        return node
    }

    func renderChildrenVNodes(_ views: [any View], modifierContext: ModifierContext = ModifierContext()) -> [VNode] {
        views.map { renderView($0, modifierContext: modifierContext) }
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
        return .element(ElementNode.build(tag: "div", id: id, classes: ["flex-grow"] + context.cssClasses))
    }

    private func renderDividerVNode(context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        return .element(ElementNode.build(tag: "hr", id: id, classes: ["divider"] + context.cssClasses))
    }

    private func renderMarkdownVNode(_ md: Markdown, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let html = MarkdownParser.html(from: md.content)
        let classes = ["markdown"] + context.cssClasses
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
        var inputAttrs = OrderedAttributes([("id", id), ("type", "checkbox"), ("data-sparrow-event", "change")])
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
        let src: String
        switch img.source {
        case .asset(let name): src = "/assets/\(escapeHTML(name))"
        case .url(let url): src = escapeHTML(url)
        }
        let classes = ["img"] + context.cssClasses
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
        let registry = IconConfiguration.registry
        guard let svgInner = registry?.svg(for: icon.systemName) else {
            // Unknown icon — render an empty span with data-icon for debugging
            let el = ElementNode.build(
                tag: "span", id: id, classes: classes,
                styles: context.inlineStyles,
                extraAttrs: [("data-icon-missing", escapeHTML(icon.systemName))]
            )
            return .element(el)
        }
        let viewBox = registry?.viewBox(for: icon.systemName) ?? "0 0 24 24"
        var extraAttrs: [(key: String, value: String)] = [
            ("xmlns", "http://www.w3.org/2000/svg"),
            ("viewBox", viewBox),
            ("width", "1em"),
            ("height", "1em"),
            ("aria-hidden", "true"),
        ]
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "svg", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: extraAttrs,
            children: [.text(svgInner)]
        )
        return .element(el)
    }

    private func renderNavigationLinkVNode(_ navLink: NavigationLink, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let isCurrent = navLink.current || renderState.currentPath == navLink.destination
        var classes = ["nav-link"] + context.cssClasses
        if isCurrent { classes.append("nav-link-current") }
        var extraAttrs: [(key: String, value: String)] = [("href", escapeHTML(navLink.destination)), ("data-sparrow-nav", "")]
        if isCurrent { extraAttrs.append(("aria-current", "page")) }
        extraAttrs.append(contentsOf: context.htmlAttributePairs)
        let el = ElementNode.build(
            tag: "a", id: id, classes: classes, styles: context.inlineStyles,
            extraAttrs: extraAttrs, children: [.text(escapeHTML(navLink.label))]
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

    // MARK: - Rive Animation

    private func renderRiveAnimationVNode(_ rive: RiveAnimation, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let src: String
        switch rive.source {
        case .asset(let name): src = "/assets/\(escapeHTML(name))"
        case .url(let url): src = escapeHTML(url)
        }
        var extraAttrs: [(key: String, value: String)] = [
            ("data-sparrow-rive", src), ("data-sparrow-rive-fit", rive.fit.rawValue),
        ]
        if let sm = rive.stateMachine { extraAttrs.append(("data-sparrow-rive-sm", escapeHTML(sm))) }
        if let artboard = rive.artboard { extraAttrs.append(("data-sparrow-rive-artboard", escapeHTML(artboard))) }
        if rive.autoplay { extraAttrs.append(("data-sparrow-rive-autoplay", "")) }
        if !rive.inputs.isEmpty { extraAttrs.append(("data-sparrow-rive-inputs", escapeHTML(serializeRiveInputs(rive.inputs)))) }
        if !rive.eventHandlers.isEmpty {
            let handlers = rive.eventHandlers
            renderState.registerValueHandler(id: id) { eventName in handlers[eventName]?() }
            extraAttrs.append(("data-sparrow-event", "rive"))
        }
        let el = ElementNode.build(tag: "canvas", id: id, classes: context.cssClasses, styles: context.inlineStyles, extraAttrs: extraAttrs)
        return .element(el)
    }

    // MARK: - Lottie Animation

    private func renderLottieAnimationVNode(_ lottie: LottieAnimation, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let src: String
        switch lottie.source {
        case .asset(let name): src = "/assets/\(escapeHTML(name))"
        case .url(let url): src = escapeHTML(url)
        }
        var extraAttrs: [(key: String, value: String)] = [("data-sparrow-lottie", src)]
        if lottie.loop { extraAttrs.append(("data-sparrow-lottie-loop", "")) }
        if lottie.autoplay { extraAttrs.append(("data-sparrow-lottie-autoplay", "")) }
        if lottie.speed != 1.0 { extraAttrs.append(("data-sparrow-lottie-speed", "\(lottie.speed)")) }
        if lottie.direction != .forward { extraAttrs.append(("data-sparrow-lottie-direction", "\(lottie.direction.rawValue)")) }
        if lottie.renderer != .svg { extraAttrs.append(("data-sparrow-lottie-renderer", lottie.renderer.rawValue)) }
        let hasHandlers = lottie.onCompleteHandler != nil || lottie.onLoopCompleteHandler != nil
        if hasHandlers {
            let onComplete = lottie.onCompleteHandler
            let onLoopComplete = lottie.onLoopCompleteHandler
            renderState.registerValueHandler(id: id) { eventName in
                switch eventName {
                case "complete": onComplete?()
                case "loopComplete": onLoopComplete?()
                default: break
                }
            }
            extraAttrs.append(("data-sparrow-event", "lottie"))
        }
        let el = ElementNode.build(tag: "div", id: id, classes: context.cssClasses, styles: context.inlineStyles, extraAttrs: extraAttrs)
        return .element(el)
    }

    // MARK: - PhaseAnimator

    private func renderPhaseAnimatorVNode(_ animator: any _PhaseAnimatorRenderable, context: ModifierContext) -> VNode {
        let phaseCount = animator._phaseCount
        guard phaseCount > 1 else {
            if phaseCount == 1 { return renderView(animator._contentForPhase(0), modifierContext: context) }
            return .fragment([])
        }

        // Render at each phase, extract inline styles from the VNode
        var phaseStyles: [[String: String]] = []
        var firstNode: VNode = .fragment([])
        for i in 0..<phaseCount {
            let node = renderView(animator._contentForPhase(i), modifierContext: ModifierContext())
            if i == 0 { firstNode = node }
            phaseStyles.append(extractVNodeStyles(node))
        }

        var allProps = Set<String>()
        for styles in phaseStyles { allProps.formUnion(styles.keys) }
        let animatedProps = allProps.filter { prop in
            Set(phaseStyles.map { $0[prop] ?? "" }).count > 1
        }
        guard !animatedProps.isEmpty else { return firstNode }

        let animName = "sp-phase-\(renderState.allocateId())"
        var keyframeCSS = "@keyframes \(animName) { "
        for (i, styles) in phaseStyles.enumerated() {
            let pct = i * 100 / (phaseCount - 1)
            let props = animatedProps.compactMap { prop -> String? in
                guard let val = styles[prop] else { return nil }
                return "\(prop): \(val)"
            }
            keyframeCSS += "\(pct)% { \(props.joined(separator: "; ")); } "
        }
        keyframeCSS += "}"

        let totalDuration = (0..<phaseCount).reduce(0.0) { $0 + animator._animationForPhase($1).duration }
        let id = resolveId(context: context)
        var animStyles = context.inlineStyles
        animStyles["animation"] = "\(animName) \(SparrowAnimation.default.formatDuration(totalDuration)) infinite"

        // Emit the @keyframes as a raw text node before the animated wrapper
        let styleNode = VNode.text("<style>\(keyframeCSS)</style>")
        let wrapperEl = ElementNode.build(tag: "div", id: id, classes: context.cssClasses, styles: animStyles, children: [firstNode])
        return .fragment([styleNode, .element(wrapperEl)])
    }

    // MARK: - KeyframeAnimator

    private func renderKeyframeAnimatorVNode(_ animator: any _KeyframeAnimatorRenderable, context: ModifierContext) -> VNode {
        let tracks = animator._tracks
        guard !tracks.isEmpty else { return renderView(animator._contentForInitial(), modifierContext: context) }

        let totalDuration = tracks.map { $0.totalDuration }.max() ?? 0
        guard totalDuration > 0 else { return renderView(animator._contentForInitial(), modifierContext: context) }

        var timePoints = Set<Double>([0])
        for track in tracks {
            var t = 0.0
            for kf in track.keyframes { t += kf.duration; timePoints.insert(t) }
        }

        let animName = "sp-kf-\(renderState.allocateId())"
        var keyframeCSS = "@keyframes \(animName) { "
        for time in timePoints.sorted() {
            let pct = Int((time / totalDuration) * 100)
            var props: [String] = []
            for track in tracks {
                var t = 0.0
                var value = track.keyframes.first?.cssValue ?? "0"
                var timing = "linear"
                for kf in track.keyframes {
                    if t + kf.duration >= time { value = kf.cssValue; timing = kf.timingFunction; break }
                    t += kf.duration; value = kf.cssValue
                }
                props.append("\(track.cssProperty): \(value)")
                if timing != "linear" { props.append("animation-timing-function: \(timing)") }
            }
            keyframeCSS += "\(pct)% { \(props.joined(separator: "; ")); } "
        }
        keyframeCSS += "}"

        let id = resolveId(context: context)
        let contentNode = renderView(animator._contentForInitial(), modifierContext: ModifierContext())
        let iterCount = animator._repeating ? "infinite" : "1"
        var animStyles = context.inlineStyles
        animStyles["animation"] = "\(animName) \(SparrowAnimation.default.formatDuration(totalDuration)) \(iterCount)"

        let styleNode = VNode.text("<style>\(keyframeCSS)</style>")
        let wrapperEl = ElementNode.build(tag: "div", id: id, classes: context.cssClasses, styles: animStyles, children: [contentNode])
        return .fragment([styleNode, .element(wrapperEl)])
    }

    // MARK: - Table primitives

    private func renderTableHeadVNode(_ th: TableHead, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["table-head"] + context.cssClasses
        let el = ElementNode.build(
            tag: "th", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: context.htmlAttributePairs,
            children: [.text(escapeHTML(th.text))]
        )
        return .element(el)
    }

    private func renderTableCaptionVNode(_ caption: TableCaption, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["table-caption"] + context.cssClasses
        let el = ElementNode.build(
            tag: "caption", id: id,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: context.htmlAttributePairs,
            children: [.text(escapeHTML(caption.text))]
        )
        return .element(el)
    }

    // MARK: - Checkbox

    private func renderCheckboxVNode(_ checkbox: Checkbox, context: ModifierContext) -> VNode {
        let labelId = resolveId(context: context)
        let buttonId = renderState.allocateId()
        let binding = checkbox.isChecked
        renderState.registerHandler(id: buttonId) { binding.wrappedValue.toggle() }

        let checked = binding.wrappedValue
        let state = checked ? "checked" : "unchecked"

        let indicatorId = renderState.allocateId()
        let indicatorEl = ElementNode.build(
            tag: "span", id: indicatorId,
            classes: ["checkbox-indicator"],
            extraAttrs: [("data-state", state)],
            children: [.text("\u{2713}")]
        )

        let buttonEl = ElementNode.build(
            tag: "button", id: buttonId,
            classes: ["checkbox-root"],
            extraAttrs: [
                ("type", "button"),
                ("role", "checkbox"),
                ("aria-checked", checked ? "true" : "false"),
                ("data-state", state),
                ("data-sparrow-event", "click"),
            ],
            children: [.element(indicatorEl)]
        )

        var labelChildren: [VNode] = [.element(buttonEl)]
        if let labelText = checkbox.label {
            let spanId = renderState.allocateId()
            let labelSpan = ElementNode.build(
                tag: "span", id: spanId,
                classes: ["checkbox-label"],
                children: [.text(escapeHTML(labelText))]
            )
            labelChildren.append(.element(labelSpan))
        }

        let classes = ["checkbox"] + context.cssClasses
        let el = ElementNode.build(
            tag: "label", id: labelId,
            classes: classes,
            styles: context.inlineStyles,
            extraAttrs: context.htmlAttributePairs,
            children: labelChildren
        )
        return .element(el)
    }

    // MARK: - RadioGroup

    private func renderRadioGroupVNode(_ radio: RadioGroup, context: ModifierContext) -> VNode {
        let groupId = resolveId(context: context)
        let binding = radio.selection
        let selected = binding.wrappedValue

        let orientationDir = radio.orientation == .vertical ? "vertical" : "horizontal"
        var groupClasses = ["radio-group"] + context.cssClasses
        if radio.orientation == .horizontal {
            groupClasses.append("radio-group-horizontal")
        }

        let itemNodes: [VNode] = radio.options.map { option in
            let itemId = renderState.allocateId()
            let buttonId = renderState.allocateId()
            let isSelected = option.value == selected
            let state = isSelected ? "checked" : "unchecked"

            let optionValue = option.value
            renderState.registerHandler(id: buttonId) { binding.wrappedValue = optionValue }

            let indicatorId = renderState.allocateId()
            let indicatorEl = ElementNode.build(
                tag: "span", id: indicatorId,
                classes: ["radio-indicator"],
                extraAttrs: [("data-state", state)]
            )

            let buttonEl = ElementNode.build(
                tag: "button", id: buttonId,
                classes: ["radio-root"],
                extraAttrs: [
                    ("type", "button"),
                    ("role", "radio"),
                    ("aria-checked", isSelected ? "true" : "false"),
                    ("data-state", state),
                    ("data-sparrow-roving-item", ""),
                    ("data-sparrow-event", "click"),
                ],
                children: [.element(indicatorEl)]
            )

            let labelSpanId = renderState.allocateId()
            let labelSpan = ElementNode.build(
                tag: "span", id: labelSpanId,
                classes: ["radio-label"],
                children: [.text(escapeHTML(option.label))]
            )

            return .element(ElementNode.build(
                tag: "label", id: itemId,
                classes: ["radio-item"],
                children: [.element(buttonEl), .element(labelSpan)]
            ))
        }

        let el = ElementNode.build(
            tag: "div", id: groupId,
            classes: groupClasses,
            styles: context.inlineStyles,
            extraAttrs: [("role", "radiogroup"), ("data-sparrow-roving", orientationDir)] + context.htmlAttributePairs,
            children: itemNodes
        )
        return .element(el)
    }

    // MARK: - Content

    private func renderContentVNode(context: ModifierContext) -> VNode {
        let contentChildren = renderState.contentSlotVNode.map { [$0] } ?? []
        let el = ElementNode.build(
            tag: "div", id: "sparrow-content",
            classes: context.cssClasses, styles: context.inlineStyles,
            children: contentChildren
        )
        return .element(el)
    }

    // MARK: - VNode ID extraction

    private func extractVNodeId(_ node: VNode) -> String? {
        switch node {
        case .element(let el): return el.id.isEmpty ? nil : el.id
        case .fragment(let nodes):
            for n in nodes {
                if let id = extractVNodeId(n) { return id }
            }
            return nil
        case .text: return nil
        }
    }

    // MARK: - Component PrimitiveView renderers

    private func renderBreadcrumbLinkVNode(_ v: BreadcrumbLink, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["breadcrumb-link"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = []
        if let href = v.href {
            extraAttrs.append(("href", escapeHTML(href)))
        }
        extraAttrs.append(contentsOf: context.allExtraAttributePairs)
        let tag = v.href != nil ? "a" : "span"
        let el = ElementNode.build(tag: tag, id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderBreadcrumbSeparatorVNode(_ v: BreadcrumbSeparator, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["breadcrumb-separator"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [("role", "presentation"), ("aria-hidden", "true")]
        extraAttrs.append(contentsOf: context.allExtraAttributePairs)
        let el = ElementNode.build(tag: "li", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text("/")])
        return .element(el)
    }

    private func renderBreadcrumbPageVNode(_ v: BreadcrumbPage, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["breadcrumb-page"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [("aria-current", "page")]
        extraAttrs.append(contentsOf: context.allExtraAttributePairs)
        let el = ElementNode.build(tag: "span", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderAvatarImageVNode(_ v: AvatarImage, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["avatar-image"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [("src", escapeHTML(v.src)), ("alt", escapeHTML(v.alt))]
        extraAttrs.append(contentsOf: context.allExtraAttributePairs)
        let el = ElementNode.build(tag: "img", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs)
        return .element(el)
    }

    private func renderAvatarFallbackVNode(_ v: AvatarFallback, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["avatar-fallback"] + context.cssClasses
        let el = ElementNode.build(tag: "span", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderLabelVNode(_ v: Label, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["label"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = []
        if let htmlFor = v.htmlFor { extraAttrs.append(("for", escapeHTML(htmlFor))) }
        extraAttrs.append(contentsOf: context.allExtraAttributePairs)
        let el = ElementNode.build(tag: "label", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderSkeletonVNode(_ v: Skeleton, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        var classes = ["skeleton"] + context.cssClasses
        if v.rounded { classes.append("skeleton-round") }
        var styles = context.inlineStyles
        if let w = v.width { styles["width"] = w }
        if let h = v.height { styles["height"] = h }
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: styles, extraAttrs: context.allExtraAttributePairs)
        return .element(el)
    }

    private func renderTabsTriggerVNode(_ v: TabsTrigger, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.onSelect)
        let state = v.isSelected ? "active" : "inactive"
        let classes = ["tabs-trigger"] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [
            ("role", "tab"),
            ("data-state", state),
            ("data-sparrow-roving-item", ""),
            ("data-sparrow-event", "click"),
        ]
        if v.isSelected { extraAttrs.append(("aria-selected", "true")) }
        extraAttrs.append(contentsOf: context.allExtraAttributePairs)
        let el = ElementNode.build(tag: "button", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderAccordionTriggerVNode(_ v: AccordionTrigger, context: ModifierContext) -> VNode {
        let headerId = resolveId(context: context)
        let buttonId = renderState.allocateId()
        renderState.registerHandler(id: buttonId, handler: v.onToggle)
        let state = v.isOpen ? "open" : "closed"
        let spanId = renderState.allocateId()
        let textSpan = ElementNode.build(tag: "span", id: spanId, children: [.text(escapeHTML(v.text))])
        let chevronId = renderState.allocateId()
        let chevron = ElementNode.build(tag: "span", id: chevronId, classes: ["accordion-chevron"], extraAttrs: [("data-state", state)], children: [.text("\u{25BE}")])
        let buttonEl = ElementNode.build(
            tag: "button", id: buttonId,
            classes: ["accordion-trigger"],
            extraAttrs: [("data-state", state), ("aria-expanded", v.isOpen ? "true" : "false"), ("data-sparrow-event", "click")],
            children: [.element(textSpan), .element(chevron)]
        )
        let el = ElementNode.build(tag: "h3", id: headerId, classes: ["accordion-header"] + context.cssClasses, children: [.element(buttonEl)])
        return .element(el)
    }

    private func renderCollapsibleTriggerVNode(_ v: CollapsibleTrigger, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.onToggle)
        let state = v.isOpen ? "open" : "closed"
        let classes = ["collapsible-trigger"] + context.cssClasses
        let extraAttrs: [(key: String, value: String)] = [
            ("data-state", state),
            ("data-sparrow-event", "click"),
        ] + context.allExtraAttributePairs
        let el = ElementNode.build(tag: "button", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderToggleGroupItemVNode(_ v: ToggleGroupItem, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.onToggle)
        let state = v.isSelected ? "on" : "off"
        let classes = ["toggle-group-item"] + context.cssClasses
        let extraAttrs: [(key: String, value: String)] = [
            ("data-state", state),
            ("data-sparrow-roving-item", ""),
            ("data-sparrow-event", "click"),
        ] + context.allExtraAttributePairs
        let el = ElementNode.build(tag: "button", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderToggleButtonVNode(_ v: ToggleButton, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.onToggle)
        let state = v.isPressed ? "on" : "off"
        let classes = ["toggle-btn", v.variant.cssClass, v.size.cssClass] + context.cssClasses
        var extraAttrs: [(key: String, value: String)] = [
            ("data-state", state),
            ("aria-pressed", v.isPressed ? "true" : "false"),
            ("data-sparrow-event", "click"),
        ]
        extraAttrs.append(contentsOf: context.allExtraAttributePairs)
        let el = ElementNode.build(tag: "button", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderDialogTitleVNode(_ v: DialogTitle, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["dialog-title"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderDialogDescriptionVNode(_ v: DialogDescription, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["dialog-description"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderDialogCloseVNode(_ v: DialogClose, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.onClose)
        let classes = ["dialog-close"] + context.cssClasses
        let extraAttrs: [(key: String, value: String)] = [("data-sparrow-event", "click")] + context.allExtraAttributePairs
        let el = ElementNode.build(tag: "button", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderDropdownMenuItemVNode(_ v: DropdownMenuItem, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.action)
        let classes = ["dropdown-item"] + context.cssClasses
        let extraAttrs: [(key: String, value: String)] = [
            ("role", "menuitem"),
            ("data-sparrow-roving-item", ""),
            ("data-sparrow-event", "click"),
        ] + context.allExtraAttributePairs
        let el = ElementNode.build(tag: "button", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderDropdownMenuSeparatorVNode(context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let el = ElementNode.build(tag: "div", id: id, classes: ["dropdown-separator"] + context.cssClasses)
        return .element(el)
    }

    private func renderDropdownMenuLabelVNode(_ v: DropdownMenuLabel, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["dropdown-label"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderSelectMenuVNode(_ v: SelectMenu, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let triggerId = renderState.allocateId()
        renderState.registerHandler(id: triggerId, handler: v.onToggle)
        let selected = v.selection.wrappedValue
        let displayLabel = v.options.first(where: { $0.value == selected })?.label

        let valueId = renderState.allocateId()
        let valueClasses = displayLabel != nil ? ["select-value"] : ["select-value", "select-placeholder"]
        let valueEl = ElementNode.build(tag: "span", id: valueId, classes: valueClasses, children: [.text(escapeHTML(displayLabel ?? v.placeholder))])
        let chevronId = renderState.allocateId()
        let chevronEl = ElementNode.build(tag: "span", id: chevronId, classes: ["select-chevron"], children: [.text("\u{25BE}")])
        let triggerEl = ElementNode.build(
            tag: "button", id: triggerId,
            classes: ["select-trigger"],
            extraAttrs: [("data-sparrow-event", "click")],
            children: [.element(valueEl), .element(chevronEl)]
        )

        var allChildren: [VNode] = [.element(triggerEl)]

        if v.isOpen {
            let binding = v.selection
            let contentId = renderState.allocateId()
            let dismissHandler = v.onDismiss
            renderState.registerHandler(id: contentId, handler: dismissHandler)
            let optionNodes: [VNode] = v.options.map { opt in
                let optId = renderState.allocateId()
                let isSelected = opt.value == selected
                let optValue = opt.value
                renderState.registerHandler(id: optId) {
                    binding.wrappedValue = optValue
                    dismissHandler()
                }
                var optAttrs: [(key: String, value: String)] = [
                    ("data-sparrow-roving-item", ""),
                    ("data-sparrow-event", "click"),
                ]
                if isSelected { optAttrs.append(("aria-selected", "true")) }
                var optChildren: [VNode] = []
                if isSelected {
                    let checkId = renderState.allocateId()
                    optChildren.append(.element(ElementNode.build(tag: "span", id: checkId, classes: ["select-item-check"], children: [.text("\u{2713}")])))
                }
                optChildren.append(.text(escapeHTML(opt.label)))
                return .element(ElementNode.build(tag: "div", id: optId, classes: ["select-item"], extraAttrs: optAttrs, children: optChildren))
            }
            let contentAttrs: [(key: String, value: String)] = [
                ("data-sparrow-floating", "bottom"),
                ("data-sparrow-floating-anchor", triggerId),
                ("data-sparrow-dismissable", triggerId),
                ("data-sparrow-roving", "vertical"),
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["select-content"], extraAttrs: contentAttrs, children: optionNodes)
            allChildren.append(.element(contentEl))
        }

        let classes = ["select-menu"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }

    private func renderCommandItemVNode(_ v: CommandItem, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.action)
        let classes = ["command-item"] + context.cssClasses
        let extraAttrs: [(key: String, value: String)] = [
            ("data-sparrow-roving-item", ""),
            ("data-sparrow-event", "click"),
        ] + context.allExtraAttributePairs
        let el = ElementNode.build(tag: "button", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: extraAttrs, children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderCommandSeparatorVNode(context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let el = ElementNode.build(tag: "div", id: id, classes: ["command-separator"] + context.cssClasses)
        return .element(el)
    }

    private func renderCommandEmptyVNode(_ v: CommandEmpty, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["command-empty"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderPaginationVNode(_ v: Pagination, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        var children: [VNode] = []

        // Previous button
        let prevId = renderState.allocateId()
        if v.currentPage > 1 {
            let prevPage = v.currentPage - 1
            renderState.registerHandler(id: prevId) { v.onPageChange(prevPage) }
            let prevEl = ElementNode.build(tag: "button", id: prevId, classes: ["pagination-item"], extraAttrs: [("data-sparrow-event", "click")], children: [.text("\u{2039}")])
            children.append(.element(prevEl))
        }

        // Page numbers
        let windowStart = max(1, v.currentPage - 2)
        let windowEnd = min(v.totalPages, v.currentPage + 2)

        if windowStart > 1 {
            let oneId = renderState.allocateId()
            renderState.registerHandler(id: oneId) { v.onPageChange(1) }
            children.append(.element(ElementNode.build(tag: "button", id: oneId, classes: ["pagination-item"], extraAttrs: [("data-sparrow-event", "click")], children: [.text("1")])))
            if windowStart > 2 {
                let ellipsisId = renderState.allocateId()
                children.append(.element(ElementNode.build(tag: "span", id: ellipsisId, classes: ["pagination-ellipsis"], children: [.text("\u{2026}")])))
            }
        }

        for page in windowStart...windowEnd {
            let pageId = renderState.allocateId()
            let pageNum = page
            renderState.registerHandler(id: pageId) { v.onPageChange(pageNum) }
            var classes = ["pagination-item"]
            if page == v.currentPage { classes.append("pagination-item-active") }
            children.append(.element(ElementNode.build(tag: "button", id: pageId, classes: classes, extraAttrs: [("data-sparrow-event", "click")], children: [.text("\(page)")])))
        }

        if windowEnd < v.totalPages {
            if windowEnd < v.totalPages - 1 {
                let ellipsisId = renderState.allocateId()
                children.append(.element(ElementNode.build(tag: "span", id: ellipsisId, classes: ["pagination-ellipsis"], children: [.text("\u{2026}")])))
            }
            let lastId = renderState.allocateId()
            renderState.registerHandler(id: lastId) { v.onPageChange(v.totalPages) }
            children.append(.element(ElementNode.build(tag: "button", id: lastId, classes: ["pagination-item"], extraAttrs: [("data-sparrow-event", "click")], children: [.text("\(v.totalPages)")])))
        }

        // Next button
        if v.currentPage < v.totalPages {
            let nextId = renderState.allocateId()
            let nextPage = v.currentPage + 1
            renderState.registerHandler(id: nextId) { v.onPageChange(nextPage) }
            let nextEl = ElementNode.build(tag: "button", id: nextId, classes: ["pagination-item"], extraAttrs: [("data-sparrow-event", "click")], children: [.text("\u{203A}")])
            children.append(.element(nextEl))
        }

        let classes = ["pagination"] + context.cssClasses
        let el = ElementNode.build(tag: "nav", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: [("aria-label", "pagination")] + context.allExtraAttributePairs, children: children)
        return .element(el)
    }

    // MARK: - AlertDialog

    private func renderAlertDialogActionVNode(_ v: AlertDialogAction, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.action)
        let classes = ["btn", "btn-default", "btn-md"] + context.cssClasses
        let el = ElementNode.build(tag: "button", id: id, classes: classes, extraAttrs: [("data-sparrow-event", "click")], children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderAlertDialogCancelVNode(_ v: AlertDialogCancel, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.action)
        let classes = ["btn", "btn-outline", "btn-md"] + context.cssClasses
        let el = ElementNode.build(tag: "button", id: id, classes: classes, extraAttrs: [("data-sparrow-event", "click")], children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    // MARK: - Spinner

    private func renderSpinnerVNode(_ v: Spinner, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["spinner", v.size.cssClass] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs)
        return .element(el)
    }

    // MARK: - Kbd

    private func renderKbdVNode(_ v: Kbd, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["kbd"] + context.cssClasses
        let el = ElementNode.build(tag: "kbd", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: [.text(escapeHTML(v.keys))])
        return .element(el)
    }

    // MARK: - Field

    private func renderFieldDescriptionVNode(_ v: FieldDescription, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["field-description"] + context.cssClasses
        let el = ElementNode.build(tag: "p", id: id, classes: classes, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderFieldErrorVNode(_ v: FieldError, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["field-error"] + context.cssClasses
        let el = ElementNode.build(tag: "p", id: id, classes: classes, extraAttrs: [("role", "alert")], children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    // MARK: - Menubar

    private func renderMenubarTriggerVNode(_ v: MenubarTrigger, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["menubar-trigger"] + context.cssClasses
        let attrs: [(key: String, value: String)] = [("role", "menuitem"), ("data-sparrow-roving-item", ""), ("data-sparrow-event", "click")]
        let el = ElementNode.build(tag: "button", id: id, classes: classes, extraAttrs: attrs, children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderMenubarItemVNode(_ v: MenubarItem, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.action)
        let classes = ["dropdown-item"] + context.cssClasses
        var children: [VNode] = [.text(escapeHTML(v.label))]
        if let shortcut = v.shortcut {
            let kbdId = renderState.allocateId()
            let kbd = ElementNode.build(tag: "kbd", id: kbdId, classes: ["menubar-shortcut"], children: [.text(escapeHTML(shortcut))])
            children.append(.element(kbd))
        }
        let attrs: [(key: String, value: String)] = [("role", "menuitem"), ("data-sparrow-roving-item", ""), ("data-sparrow-event", "click")]
        let el = ElementNode.build(tag: "button", id: id, classes: classes, extraAttrs: attrs, children: children)
        return .element(el)
    }

    // MARK: - NavigationMenu

    private func renderNavMenuTriggerVNode(_ v: NavigationMenuTrigger, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["nav-menu-trigger"] + context.cssClasses
        let state = v.isOpen ? "open" : "closed"
        let attrs: [(key: String, value: String)] = [("data-state", state), ("data-sparrow-event", "click")]
        let el = ElementNode.build(tag: "button", id: id, classes: classes, extraAttrs: attrs, children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderNavMenuLinkVNode(_ v: NavigationMenuLink, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["nav-menu-link"] + context.cssClasses
        let el = ElementNode.build(tag: "a", id: id, classes: classes, extraAttrs: [("href", escapeHTML(v.href)), ("data-sparrow-nav", "")], children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    // MARK: - Combobox

    private func renderComboboxVNode(_ v: Combobox, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let triggerId = renderState.allocateId()
        renderState.registerHandler(id: triggerId, handler: v.onToggle)
        let selectedLabel = v.options.first(where: { $0.value == v.selection.wrappedValue })?.label
        let triggerText = selectedLabel ?? v.placeholder
        let triggerEl = ElementNode.build(tag: "button", id: triggerId, classes: ["select-trigger"], extraAttrs: [("role", "combobox"), ("aria-expanded", v.isOpen ? "true" : "false"), ("data-sparrow-event", "click")], children: [.text(escapeHTML(triggerText))])
        var allChildren: [VNode] = [.element(triggerEl)]

        if v.isOpen {
            let contentId = renderState.allocateId()
            // Search input
            let inputId = renderState.allocateId()
            let searchBinding = v.search
            renderState.registerValueHandler(id: inputId) { value in searchBinding.wrappedValue = value }
            let inputEl = ElementNode.build(tag: "input", id: inputId, classes: ["command-input"], extraAttrs: [("placeholder", escapeHTML(v.placeholder)), ("data-sparrow-event", "input"), ("data-sparrow-debounce", "150"), ("value", escapeHTML(v.search.wrappedValue))])
            let inputWrapper = ElementNode.build(tag: "div", id: renderState.allocateId(), classes: ["command-input-wrapper"], children: [.element(inputEl)])
            // Options
            var optionNodes: [VNode] = []
            for opt in v.options {
                let optId = renderState.allocateId()
                let isSelected = opt.value == v.selection.wrappedValue
                let selBinding = v.selection
                let optValue = opt.value
                renderState.registerHandler(id: optId) { selBinding.wrappedValue = optValue }
                let attrs: [(key: String, value: String)] = [("role", "option"), ("aria-selected", isSelected ? "true" : "false"), ("data-sparrow-roving-item", ""), ("data-sparrow-event", "click")]
                let optEl = ElementNode.build(tag: "div", id: optId, classes: ["command-item"], extraAttrs: attrs, children: [.text(escapeHTML(opt.label))])
                optionNodes.append(.element(optEl))
            }
            let listEl = ElementNode.build(tag: "div", id: renderState.allocateId(), classes: ["command-list"], extraAttrs: [("data-sparrow-roving", "vertical")], children: optionNodes)
            let contentAttrs: [(key: String, value: String)] = [("data-sparrow-floating", "bottom"), ("data-sparrow-floating-anchor", triggerId), ("data-sparrow-dismissable", triggerId)]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["command"], extraAttrs: contentAttrs, children: [.element(inputWrapper), .element(listEl)])
            allChildren.append(.element(contentEl))
        }

        let classes = ["combobox"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }

    // MARK: - InputOTP

    private func renderInputOTPVNode(_ v: InputOTP, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let current = v.value.wrappedValue
        var slots: [VNode] = []
        for i in 0..<v.maxLength {
            let slotId = renderState.allocateId()
            let char = i < current.count ? String(current[current.index(current.startIndex, offsetBy: i)]) : ""
            let isFilled = !char.isEmpty
            var classes = ["otp-slot"]
            if isFilled { classes.append("otp-slot-filled") }
            let slotEl = ElementNode.build(tag: "div", id: slotId, classes: classes, children: [.text(escapeHTML(char))])
            slots.append(.element(slotEl))
        }
        // Hidden input for actual value
        let inputId = renderState.allocateId()
        let binding = v.value
        renderState.registerValueHandler(id: inputId) { newValue in binding.wrappedValue = newValue }
        let inputEl = ElementNode.build(tag: "input", id: inputId, classes: ["otp-input"], extraAttrs: [("type", "text"), ("inputmode", "numeric"), ("maxlength", "\(v.maxLength)"), ("value", escapeHTML(current)), ("data-sparrow-event", "input"), ("autocomplete", "one-time-code")])
        let classes = ["otp-group"] + context.cssClasses
        var children: [VNode] = slots
        children.append(.element(inputEl))
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: children)
        return .element(el)
    }

    // MARK: - Resizable

    private func renderResizableHandleVNode(_ v: ResizableHandle, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        var classes = ["resizable-handle"] + context.cssClasses
        var children: [VNode] = []
        if v.withHandle {
            classes.append("resizable-handle-visible")
            let gripId = renderState.allocateId()
            let grip = ElementNode.build(tag: "div", id: gripId, classes: ["resizable-grip"])
            children.append(.element(grip))
        }
        let el = ElementNode.build(tag: "div", id: id, classes: classes, extraAttrs: [("data-panel-resize-handle", "")], children: children)
        return .element(el)
    }

    // MARK: - Calendar

    private func renderCalendarVNode(_ v: Calendar, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["calendar"] + context.cssClasses
        // Calendar renders a month grid — server provides the current month string
        // and selected date. Client-side navigation via prev/next month buttons.
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: [("role", "application"), ("aria-label", "Calendar")] + context.allExtraAttributePairs)
        return .element(el)
    }

    // MARK: - Carousel nav

    private func renderCarouselNavVNode(_ action: @escaping @Sendable () -> Void, label: String, cssClass: String, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: action)
        let classes = ["btn", "btn-outline", "btn-icon", cssClass] + context.cssClasses
        let el = ElementNode.build(tag: "button", id: id, classes: classes, extraAttrs: [("data-sparrow-event", "click")], children: [.text(label)])
        return .element(el)
    }

    // MARK: - Sidebar

    private func renderSidebarGroupLabelVNode(_ v: SidebarGroupLabel, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["sidebar-group-label"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderSidebarMenuButtonVNode(_ v: SidebarMenuButton, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.action)
        var classes = ["sidebar-menu-button"] + context.cssClasses
        if v.isActive { classes.append("sidebar-menu-button-active") }
        let el = ElementNode.build(tag: "button", id: id, classes: classes, extraAttrs: [("data-sparrow-event", "click"), ("data-active", v.isActive ? "true" : "false")], children: [.text(escapeHTML(v.label))])
        return .element(el)
    }

    private func renderSidebarTriggerVNode(_ v: SidebarTrigger, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.onToggle)
        let classes = ["sidebar-trigger"] + context.cssClasses
        let el = ElementNode.build(tag: "button", id: id, classes: classes, extraAttrs: [("data-sparrow-event", "click")], children: [.text("\u{2630}")])
        return .element(el)
    }

    private func renderSidebarRailVNode(_ v: SidebarRail, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        renderState.registerHandler(id: id, handler: v.onToggle)
        let classes = ["sidebar-rail"] + context.cssClasses
        let el = ElementNode.build(tag: "button", id: id, classes: classes, extraAttrs: [("data-sparrow-event", "click"), ("aria-label", "Toggle Sidebar")])
        return .element(el)
    }

    // MARK: - Toaster

    private func renderToasterVNode(_ v: Toaster, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        var toastNodes: [VNode] = []
        for toast in v.toasts {
            let toastId = renderState.allocateId()
            let dismissId = renderState.allocateId()
            let toastIdStr = toast.id
            renderState.registerHandler(id: dismissId) { v.onDismiss(toastIdStr) }
            var children: [VNode] = []
            let titleId = renderState.allocateId()
            children.append(.element(ElementNode.build(tag: "div", id: titleId, classes: ["toast-title"], children: [.text(escapeHTML(toast.title))])))
            if let desc = toast.description {
                let descId = renderState.allocateId()
                children.append(.element(ElementNode.build(tag: "div", id: descId, classes: ["toast-description"], children: [.text(escapeHTML(desc))])))
            }
            if let action = toast.action {
                let actionId = renderState.allocateId()
                renderState.registerHandler(id: actionId, handler: action.action)
                children.append(.element(ElementNode.build(tag: "button", id: actionId, classes: ["toast-action"], extraAttrs: [("data-sparrow-event", "click")], children: [.text(escapeHTML(action.label))])))
            }
            let closeBtn = ElementNode.build(tag: "button", id: dismissId, classes: ["toast-close"], extraAttrs: [("data-sparrow-event", "click")], children: [.text("\u{2715}")])
            children.append(.element(closeBtn))
            let classes = ["toast", toast.variant.cssClass]
            let toastEl = ElementNode.build(tag: "div", id: toastId, classes: classes, extraAttrs: [("role", "alert")], children: children)
            toastNodes.append(.element(toastEl))
        }
        let classes = ["toaster"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: toastNodes)
        return .element(el)
    }

    // MARK: - Drawer primitives

    private func renderDrawerTitleVNode(_ v: DrawerTitle, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["drawer-title"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    private func renderDrawerDescriptionVNode(_ v: DrawerDescription, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = ["drawer-description"] + context.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, children: [.text(escapeHTML(v.text))])
        return .element(el)
    }

    // MARK: - Typography

    private func renderTypographyVNode(_ text: String, tag: String, cssClass: String, context: ModifierContext) -> VNode {
        let id = resolveId(context: context)
        let classes = [cssClass] + context.cssClasses
        let el = ElementNode.build(tag: tag, id: id, classes: classes, styles: context.inlineStyles, extraAttrs: context.allExtraAttributePairs, children: [.text(escapeHTML(text))])
        return .element(el)
    }

    // MARK: - VNode style extraction

    private func extractVNodeStyles(_ node: VNode) -> [String: String] {
        guard case .element(let el) = node,
              let styleStr = el.attributes["style"] else { return [:] }
        var result: [String: String] = [:]
        for pair in styleStr.split(separator: ";") {
            let parts = pair.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                result[parts[0].trimmingCharacters(in: .whitespaces)] = parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return result
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

func serializeRiveInputs(_ inputs: [String: RiveInputValue]) -> String {
    let pairs = inputs.map { key, value in
        let jsonKey = "\"\(key)\""
        switch value {
        case .bool(let b): return "\(jsonKey):\(b)"
        case .number(let n): return "\(jsonKey):\(n)"
        case .trigger: return "\(jsonKey):\"__trigger__\""
        }
    }
    return "{\(pairs.joined(separator: ","))}"
}

func formatHTMLAttributes(_ attrs: [String: String]) -> String {
    guard !attrs.isEmpty else { return "" }
    return attrs.sorted(by: { $0.key < $1.key })
        .map { " \($0.key)=\"\(escapeHTML($0.value))\"" }
        .joined()
}
