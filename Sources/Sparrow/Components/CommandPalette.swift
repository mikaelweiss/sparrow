/// Command palette matching ShadCN Command.
public struct CommandPalette<Content: View>: View {
    let search: Binding<String>
    let placeholder: String
    let content: Content
    public init(search: Binding<String>, placeholder: String = "Type a command...", @ViewBuilder content: () -> Content) {
        self.search = search
        self.placeholder = placeholder
        self.content = content()
    }
    public var body: Never { fatalError() }
}

public struct CommandGroup<Content: View>: View {
    let heading: String
    let content: Content
    public init(_ heading: String, @ViewBuilder content: () -> Content) {
        self.heading = heading
        self.content = content()
    }
    public var body: Never { fatalError() }
}

public struct CommandItem: PrimitiveView, Sendable {
    public let label: String
    public let action: @Sendable () -> Void
    public init(_ label: String, action: @escaping @Sendable () -> Void) {
        self.label = label
        self.action = action
    }
}

public struct CommandSeparator: PrimitiveView, Sendable {
    public init() {}
}

public struct CommandEmpty: PrimitiveView, Sendable {
    public let text: String
    public init(_ text: String = "No results found.") { self.text = text }
}

// MARK: - Sendable

extension CommandPalette: Sendable where Content: Sendable {}
extension CommandGroup: Sendable where Content: Sendable {}

// MARK: - VNodeRenderable

extension CommandPalette: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)

        // Search input
        let inputId = renderer.renderState.allocateId()
        renderer.renderState.registerValueHandler(id: inputId) { [search] value in
            search.wrappedValue = value
        }
        let inputAttrs: [(key: String, value: String)] = [
            (key: "placeholder", value: escapeHTML(placeholder)),
            (key: "data-sparrow-event", value: "input"),
            (key: "data-sparrow-debounce", value: "150"),
            (key: "value", value: escapeHTML(search.wrappedValue))
        ]
        let input = ElementNode.build(tag: "input", id: inputId, classes: ["command-input"], extraAttrs: inputAttrs)
        let inputWrapperId = renderer.renderState.allocateId()
        let inputWrapper = ElementNode.build(tag: "div", id: inputWrapperId, classes: ["command-input-wrapper"], children: [.element(input)])

        // Separator
        let sepId = renderer.renderState.allocateId()
        let sep = ElementNode.build(tag: "div", id: sepId, classes: ["command-separator"])

        // List
        let listId = renderer.renderState.allocateId()
        let listChildren = renderer.renderChildrenVNodes(flattenChildren(content))
        let listAttrs: [(key: String, value: String)] = [
            (key: "data-sparrow-roving", value: "vertical")
        ]
        let list = ElementNode.build(tag: "div", id: listId, classes: ["command-list"], extraAttrs: listAttrs, children: listChildren)

        let classes = ["command"] + modifierContext.cssClasses
        var extraAttrs = modifierContext.allExtraAttributePairs
        extraAttrs.append((key: "role", value: "dialog"))
        extraAttrs.append((key: "data-sparrow-focus-trap", value: ""))
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: extraAttrs, children: [.element(inputWrapper), .element(sep), .element(list)])
        return .element(el)
    }
}

extension CommandGroup: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let headingId = renderer.renderState.allocateId()
        let heading = ElementNode.build(tag: "div", id: headingId, classes: ["command-group-heading"], children: [.text(escapeHTML(self.heading))])
        let children = flattenChildren(content)
        let childNodes = renderer.renderChildrenVNodes(children)
        var allChildren: [VNode] = [.element(heading)]
        allChildren.append(contentsOf: childNodes)
        let el = ElementNode.build(tag: "div", id: id, classes: ["command-group"], children: allChildren)
        return .element(el)
    }
}
