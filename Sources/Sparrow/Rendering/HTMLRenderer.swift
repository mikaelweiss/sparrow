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
