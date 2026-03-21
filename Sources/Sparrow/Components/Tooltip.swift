/// CSS-only tooltip matching ShadCN Tooltip.
public struct Tooltip<Trigger: View>: View {
    let text: String
    let side: FloatingSide
    let trigger: Trigger
    public init(_ text: String, side: FloatingSide = .top, @ViewBuilder trigger: () -> Trigger) {
        self.text = text
        self.side = side
        self.trigger = trigger()
    }
    public var body: Never { fatalError() }
}

public enum FloatingSide: String, Sendable { case top, bottom, left, right }

extension Tooltip: Sendable where Trigger: Sendable {}

extension Tooltip: VNodeRenderable {
    func renderVNode(with renderer: HTMLRenderer, modifierContext: ModifierContext) -> VNode {
        let id = renderer.resolveId(context: modifierContext)
        let triggerId = renderer.renderState.allocateId()
        let triggerNode = renderer.renderView(trigger, modifierContext: ModifierContext())

        let tooltipId = renderer.renderState.allocateId()
        let tooltipAttrs: [(key: String, value: String)] = [
            (key: "role", value: "tooltip"),
            (key: "data-sparrow-floating", value: side.rawValue),
            (key: "data-sparrow-floating-anchor", value: triggerId)
        ]
        let tooltipEl = ElementNode.build(tag: "div", id: tooltipId, classes: ["tooltip-content"], extraAttrs: tooltipAttrs, children: [.text(escapeHTML(text))])

        let classes = ["tooltip-wrapper"] + modifierContext.cssClasses
        let el = ElementNode.build(tag: "div", id: id, classes: classes, styles: modifierContext.inlineStyles, extraAttrs: modifierContext.allExtraAttributePairs, children: [triggerNode, .element(tooltipEl)])
        return .element(el)
    }
}
