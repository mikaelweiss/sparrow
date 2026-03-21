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

// MARK: - Card

extension Card: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["card"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
    }
}

// MARK: - Modal

extension Modal: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        guard isPresented else { return "" }
        let id = renderer.renderState.allocateId()
        let dismissId = renderer.renderState.allocateId()
        // Register a dismiss handler that toggles the binding
        let binding = self.isPresentedBinding
        if let binding {
            renderer.renderState.registerHandler(id: dismissId) {
                binding.wrappedValue = false
            }
        }
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["modal"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div class="modal-overlay" data-sparrow-dismissable="\(dismissId)">
                    <dialog id="\(id)"\(classAttr)\(styleAttr) open data-sparrow-focus-trap aria-modal="true" role="dialog" data-sparrow-enter="modal-enter" data-sparrow-exit="modal-exit">
        \(childrenHTML)
                    </dialog>
                </div>
                <div class="modal-backdrop"></div>
        """
    }
}

// MARK: - Sheet

extension Sheet: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        guard isPresented else { return "" }
        let id = renderer.renderState.allocateId()
        let dismissId = renderer.renderState.allocateId()
        if let binding = self.isPresentedBinding {
            renderer.renderState.registerHandler(id: dismissId) {
                binding.wrappedValue = false
            }
        }
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["sheet", "sheet-open"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div class="sheet-overlay" data-sparrow-dismissable="\(dismissId)">
                    <div id="\(id)"\(classAttr)\(styleAttr) data-sparrow-focus-trap role="dialog" aria-modal="true">
        \(childrenHTML)
                    </div>
                </div>
                <div class="modal-backdrop"></div>
        """
    }
}

// MARK: - Menu

extension Menu: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let triggerId = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["menu"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        let escaped = escapeHTML(label)
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
                    <button id="\(triggerId)" class="menu-trigger" aria-haspopup="true" data-sparrow-menu-trigger>\(escaped)</button>
                    <div class="menu-content" role="menu" data-sparrow-dismissable="\(triggerId)">
        \(childrenHTML)
                    </div>
                </div>
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

// MARK: - Tooltip

extension Tooltip: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let tooltipId = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["tooltip-wrapper", "desktop-only-hover"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        let escaped = escapeHTML(text)
        return """
                <div id="\(id)"\(classAttr)\(styleAttr) data-sparrow-tooltip>
        \(childrenHTML)
                    <span id="\(tooltipId)" class="tooltip-text" role="tooltip">\(escaped)</span>
                </div>
        """
    }
}

// MARK: - Popover

extension Popover: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        // Desktop: floating popover. Mobile: bottom sheet (via CSS).
        var classes = ["popover"] + modifierContext.cssClasses
        if isPresented {
            classes.append("popover-open")
        }
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
                    <div class="popover-content">
        \(childrenHTML)
                    </div>
                </div>
        """
    }
}

// MARK: - HoverCard

extension HoverCard: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let triggerChildren = flattenChildren(trigger)
        let triggerHTML = renderer.renderChildren(triggerChildren)
        let contentChildren = flattenChildren(content)
        let contentHTML = renderer.renderChildren(contentChildren)
        let classes = ["hover-card", "desktop-only-hover"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
                    <div class="hover-card-trigger">
        \(triggerHTML)
                    </div>
                    <div class="hover-card-content">
        \(contentHTML)
                    </div>
                </div>
        """
    }
}

// MARK: - Drawer

extension Drawer: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        guard isPresented else { return "" }
        let id = renderer.renderState.allocateId()
        let dismissId = renderer.renderState.allocateId()
        if let binding = self.isPresentedBinding {
            renderer.renderState.registerHandler(id: dismissId) {
                binding.wrappedValue = false
            }
        }
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["drawer", "drawer-\(edge.rawValue)", "drawer-open"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
                    <div class="drawer-backdrop" data-sparrow-dismissable="\(dismissId)"></div>
                    <div class="drawer-panel" data-sparrow-focus-trap role="dialog" aria-modal="true">
        \(childrenHTML)
                    </div>
                </div>
        """
    }
}

// MARK: - DisclosureGroup

extension DisclosureGroup: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["disclosure"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        let open = isExpanded ? " open" : ""
        let escaped = escapeHTML(label)
        return """
                <details id="\(id)"\(classAttr)\(styleAttr)\(open)>
                    <summary class="disclosure-header">\(escaped)</summary>
                    <div class="disclosure-content">
        \(childrenHTML)
                    </div>
                </details>
        """
    }
}

// MARK: - TabView

extension TabView: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let classes = ["tab-view"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""

        // Extract Tab children
        var tabBarHTML = ""
        var tabContentHTML = ""
        for child in children {
            if let tab = child as? any TabProtocol {
                let tabId = renderer.renderState.allocateId()
                let isActive = tab.tag == selection
                let activeCls = isActive ? " tab-btn-active" : ""
                let iconHTML = tab.icon.map { "<span class=\"tab-icon\" data-icon=\"\(escapeHTML($0))\"></span>" } ?? ""
                let ariaSelected = isActive ? " aria-selected=\"true\"" : " aria-selected=\"false\""
                let tabindex = isActive ? " tabindex=\"0\"" : " tabindex=\"-1\""
                tabBarHTML += "            <button id=\"\(tabId)\" class=\"tab-btn\(activeCls)\" role=\"tab\"\(ariaSelected)\(tabindex) data-sparrow-roving-item data-sparrow-event=\"click\">\(iconHTML)\(escapeHTML(tab.label))</button>\n"
                if isActive {
                    tabContentHTML = tab.renderContent(with: renderer)
                }
            } else {
                // Non-Tab children rendered directly
                tabContentHTML += renderer.renderAnyErased(child, modifierContext: ModifierContext())
            }
        }

        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
                    <div class="tab-bar" role="tablist" data-sparrow-roving="horizontal">
        \(tabBarHTML)            </div>
                    <div class="tab-content" role="tabpanel">
        \(tabContentHTML)
                    </div>
                </div>
        """
    }
}

// MARK: - Tab

extension Tab: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        // Tab is rendered by TabView, not independently
        let children = flattenChildren(content)
        return renderer.renderChildren(children, modifierContext: modifierContext)
    }
}

// MARK: - NavigationBar

extension NavigationBar: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let classes = ["nav-bar"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""

        let leadingChildren = flattenChildren(leading)
        let leadingHTML = renderer.renderChildren(leadingChildren)
        let trailingChildren = flattenChildren(trailing)
        let trailingHTML = renderer.renderChildren(trailingChildren)
        let escaped = escapeHTML(title)

        return """
                <nav id="\(id)"\(classAttr)\(styleAttr)>
                    <div class="nav-bar-leading">
        \(leadingHTML)
                    </div>
                    <div class="nav-bar-title">\(escaped)</div>
                    <div class="nav-bar-trailing">
        \(trailingHTML)
                    </div>
                </nav>
        """
    }
}

// MARK: - Sidebar

extension Sidebar: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["sidebar"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <aside id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </aside>
        """
    }
}

// MARK: - SidebarHeader

extension SidebarHeader: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["sidebar-header"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
    }
}

// MARK: - SidebarFooter

extension SidebarFooter: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["sidebar-footer"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
    }
}

// MARK: - SidebarLayout

extension SidebarLayout: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let sidebarChildren = flattenChildren(sidebar)
        let sidebarHTML = renderer.renderChildren(sidebarChildren)
        let mainChildren = flattenChildren(main)
        let mainHTML = renderer.renderChildren(mainChildren)
        let classes = ["sidebar-layout"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""

        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
                    <div class="sidebar-layout-sidebar">
                        <button class="sidebar-collapse-btn" aria-label="Collapse sidebar">
                            <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M10 12L6 8l4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        </button>
        \(sidebarHTML)
                    </div>
                    <div class="sidebar-layout-main">
                        <button class="sidebar-mobile-toggle" aria-label="Open menu">
                            <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M3 5h14M3 10h14M3 15h14" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
                        </button>
        \(mainHTML)
                    </div>
                </div>
        """
    }
}

// MARK: - Footer

extension Footer: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["footer"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""

        return """
                <footer id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </footer>
        """
    }
}

// MARK: - FooterColumn

extension FooterColumn: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["footer-column"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""
        let escaped = escapeHTML(heading)

        return """
                <nav id="\(id)"\(classAttr)\(styleAttr) aria-label="\(escaped)">
                    <h3 class="footer-column-heading">\(escaped)</h3>
        \(childrenHTML)
                </nav>
        """
    }
}

// MARK: - FooterBottom

extension FooterBottom: HTMLRenderable {
    func renderHTML(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> String {
        let id = renderer.renderState.allocateId()
        let children = flattenChildren(content)
        let childrenHTML = renderer.renderChildren(children)
        let classes = ["footer-bottom"] + modifierContext.cssClasses
        let classAttr = " class=\"\(classes.joined(separator: " "))\""
        let styleAttr = modifierContext.inlineStyles.isEmpty ? "" : " style=\"\(formatStyles(modifierContext.inlineStyles))\""

        return """
                <div id="\(id)"\(classAttr)\(styleAttr)>
        \(childrenHTML)
                </div>
        """
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
