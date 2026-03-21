import Testing
@testable import Sparrow

@Suite("VNode Diffing")
struct VNodeDiffTests {

    // MARK: - Identical trees produce no patches

    @Test("Identical trees produce empty patches")
    func identicalTrees() {
        let node = VNode.element(ElementNode.build(
            tag: "div", id: "v0",
            classes: ["flex"],
            children: [.text("Hello")]
        ))
        let patches = diffVNode(old: node, new: node, parentId: "root")
        #expect(patches.isEmpty)
    }

    // MARK: - Text changes

    @Test("Text change produces text patch")
    func textChange() {
        let old = VNode.element(ElementNode.build(
            tag: "p", id: "v0",
            children: [.text("Hello")]
        ))
        let new = VNode.element(ElementNode.build(
            tag: "p", id: "v0",
            children: [.text("World")]
        ))
        let patches = diffVNode(old: old, new: new, parentId: "root")
        #expect(patches.count == 1)
        #expect(patches[0].op == "text")
        #expect(patches[0].target == "#v0")
        #expect(patches[0].value == "World")
    }

    // MARK: - Attribute changes

    @Test("Class change produces attr patch")
    func classChange() {
        let old = VNode.element(ElementNode.build(tag: "div", id: "v0", classes: ["btn"]))
        let new = VNode.element(ElementNode.build(tag: "div", id: "v0", classes: ["btn", "active"]))
        let patches = diffVNode(old: old, new: new, parentId: "root")
        #expect(patches.count == 1)
        #expect(patches[0].op == "attr")
        #expect(patches[0].attr == "class")
        #expect(patches[0].value == "btn active")
    }

    @Test("Removed attribute produces removeAttr patch")
    func removedAttribute() {
        let old = VNode.element(ElementNode(
            tag: "input", id: "v0",
            attributes: OrderedAttributes([("id", "v0"), ("checked", "")])
        ))
        let new = VNode.element(ElementNode(
            tag: "input", id: "v0",
            attributes: OrderedAttributes([("id", "v0")])
        ))
        let patches = diffVNode(old: old, new: new, parentId: "root")
        #expect(patches.contains(where: { $0.op == "removeAttr" && $0.attr == "checked" }))
    }

    // MARK: - Tag changes

    @Test("Different tag produces replace patch")
    func tagChange() {
        let old = VNode.element(ElementNode.build(tag: "p", id: "v0", children: [.text("text")]))
        let new = VNode.element(ElementNode.build(tag: "h2", id: "v0", children: [.text("text")]))
        let patches = diffVNode(old: old, new: new, parentId: "root")
        #expect(patches.count == 1)
        #expect(patches[0].op == "replace")
    }

    // MARK: - Child additions and removals

    @Test("Added child produces append patch")
    func addedChild() {
        let child1 = VNode.element(ElementNode.build(tag: "p", id: "c0", children: [.text("A")]))
        let child2 = VNode.element(ElementNode.build(tag: "p", id: "c1", children: [.text("B")]))
        let old = VNode.element(ElementNode.build(tag: "div", id: "v0", children: [child1]))
        let new = VNode.element(ElementNode.build(tag: "div", id: "v0", children: [child1, child2]))
        let patches = diffVNode(old: old, new: new, parentId: "root")
        #expect(patches.contains(where: { $0.op == "append" && $0.target == "#v0" }))
    }

    @Test("Removed child produces remove patch")
    func removedChild() {
        let child1 = VNode.element(ElementNode.build(tag: "p", id: "c0", children: [.text("A")]))
        let child2 = VNode.element(ElementNode.build(tag: "p", id: "c1", children: [.text("B")]))
        let old = VNode.element(ElementNode.build(tag: "div", id: "v0", children: [child1, child2]))
        let new = VNode.element(ElementNode.build(tag: "div", id: "v0", children: [child1]))
        let patches = diffVNode(old: old, new: new, parentId: "root")
        #expect(patches.contains(where: { $0.op == "remove" && $0.target == "#c1" }))
    }

    // MARK: - VNode to HTML round-trip

    @Test("VNode toHTML produces valid HTML")
    func vnodeToHTML() {
        let node = VNode.element(ElementNode.build(
            tag: "div", id: "v0",
            classes: ["flex", "flex-col"],
            children: [
                .element(ElementNode.build(tag: "p", id: "v1", children: [.text("Hello")])),
                .element(ElementNode.build(tag: "img", id: "v2", extraAttrs: [("src", "/test.png"), ("alt", "test")])),
            ]
        ))
        let html = node.toHTML()
        #expect(html.contains("<div"))
        #expect(html.contains("class=\"flex flex-col\""))
        #expect(html.contains("<p"))
        #expect(html.contains("Hello"))
        #expect(html.contains("<img"))
        #expect(html.contains("alt=\"test\""))
        // img should be self-closing (no </img>)
        #expect(!html.contains("</img>"))
    }

    // MARK: - VNode rendering integration

    @Test("HTMLRenderer.render produces VNode on renderState")
    func renderProducesVNode() {
        let renderer = HTMLRenderer()
        let _ = renderer.render(Text("Hello"))
        #expect(renderer.renderState.rootVNode != nil)
    }

}
