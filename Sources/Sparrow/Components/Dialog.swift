/// Dialog component matching ShadCN Dialog.
/// Dialog is a VNodeRenderable because it needs to manage overlay, focus trap,
/// and dismissable layer — these require coordinated element IDs that can't be
/// expressed through body composition alone.
public struct Dialog<Trigger: View, DialogBody: View>: View {
    let isOpen: Bool
    let onDismiss: @Sendable () -> Void
    let trigger: Trigger
    let dialogBody: DialogBody
    public init(isOpen: Bool, onDismiss: @escaping @Sendable () -> Void, @ViewBuilder trigger: () -> Trigger, @ViewBuilder content: () -> DialogBody) {
        self.isOpen = isOpen
        self.onDismiss = onDismiss
        self.trigger = trigger()
        self.dialogBody = content()
    }
    public var body: Never { fatalError() }
}

/// Dialog sub-parts — composites using primitives.
public struct DialogContent<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
    }
}

public struct DialogHeader<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
        }
    }
}

public struct DialogFooter<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack {
            content
        }
    }
}

public struct DialogTitle: View, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.title3)
            .fontWeight(.semibold)
            .tracking(-0.025)
    }
}

public struct DialogDescription: View, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.body)
            .foreground(.mutedForeground)
    }
}

/// Close button — PrimitiveView because it registers a click handler.
public struct DialogClose: PrimitiveView, Sendable {
    public let label: String
    public let onClose: @Sendable () -> Void
    public init(_ label: String = "✕", onClose: @escaping @Sendable () -> Void) {
        self.label = label
        self.onClose = onClose
    }
}

extension Dialog: Sendable where Trigger: Sendable, DialogBody: Sendable {}
extension DialogContent: Sendable where Content: Sendable {}
extension DialogHeader: Sendable where Content: Sendable {}
extension DialogFooter: Sendable where Content: Sendable {}

// Dialog stays VNodeRenderable — it coordinates overlay + focus trap + dismissable IDs.
extension Dialog: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let triggerId = renderer.renderState.allocateId()
        renderer.renderState.registerHandler(id: triggerId, handler: onDismiss)
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())
        var allChildren: [VNode] = [triggerNode]

        if isOpen {
            let overlayId = renderer.renderState.allocateId()
            let overlay = ElementNode.build(tag: "div", id: overlayId, classes: ["dialog-overlay"])
            allChildren.append(.element(overlay))

            let contentId = renderer.renderState.allocateId()
            let bodyNodes = renderer.renderChildrenVNodes(flattenChildren(dialogBody))
            let contentAttrs: [(key: String, value: String)] = [
                (key: "role", value: "dialog"),
                (key: "aria-modal", value: "true"),
                (key: "data-sparrow-focus-trap", value: ""),
                (key: "data-sparrow-dismissable", value: triggerId)
            ]
            let contentEl = ElementNode.build(tag: "div", id: contentId, classes: ["dialog-content"], extraAttrs: contentAttrs, children: bodyNodes)
            allChildren.append(.element(contentEl))
        }

        let el = ElementNode.build(tag: "div", id: id, classes: modifierContext.cssClasses, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: allChildren)
        return .element(el)
    }
}
