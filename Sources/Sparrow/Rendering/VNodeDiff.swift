/// Compare two VNode trees and produce a list of targeted DOM patches.
/// Uses element IDs as stable anchors — every Sparrow element has a deterministic ID
/// from RenderState.allocateId(), so we match by ID rather than tree position.
func diffVNode(old: VNode, new: VNode, parentId: String) -> [Patch] {
    // Fast path: identical trees produce no patches
    if old == new { return [] }

    switch (old, new) {
    case (.text(let oldText), .text(let newText)):
        if oldText != newText {
            return [Patch(op: "text", target: "#\(parentId)", value: newText)]
        }
        return []

    case (.element(let oldEl), .element(let newEl)):
        return diffElements(old: oldEl, new: newEl)

    case (.fragment(let oldNodes), .fragment(let newNodes)):
        return diffChildLists(
            old: flattenVNodes(oldNodes),
            new: flattenVNodes(newNodes),
            parentId: parentId
        )

    default:
        // Node type changed entirely — replace at parent level.
        // For elements, replace by their ID. For text/fragment, replace parent.
        if case .element(let newEl) = new {
            if case .element(let oldEl) = old {
                return [Patch(op: "replace", target: "#\(oldEl.id)", html: new.toHTML())]
            }
            return [Patch(op: "replace", target: "#\(parentId)", html: VNode.element(newEl).toHTML())]
        }
        // Fallback: full replace of parent
        return [Patch(op: "replaceInner", target: "#\(parentId)", html: new.toHTML())]
    }
}

/// Diff two elements with the same or different tags.
private func diffElements(old: ElementNode, new: ElementNode) -> [Patch] {
    // Different tag = full replace
    if old.tag != new.tag {
        return [Patch(op: "replace", target: "#\(old.id)", html: VNode.element(new).toHTML())]
    }

    // Different ID = full replace (shouldn't happen in practice with deterministic IDs)
    if old.id != new.id {
        return [Patch(op: "replace", target: "#\(old.id)", html: VNode.element(new).toHTML())]
    }

    var patches: [Patch] = []
    let id = old.id

    // Diff attributes
    patches.append(contentsOf: diffAttributes(old: old.attributes, new: new.attributes, id: id))

    // Diff children
    let oldChildren = flattenVNodes(old.children)
    let newChildren = flattenVNodes(new.children)
    patches.append(contentsOf: diffChildLists(old: oldChildren, new: newChildren, parentId: id))

    return patches
}

/// Diff attribute lists and produce attr/removeAttr patches.
private func diffAttributes(old: OrderedAttributes, new: OrderedAttributes, id: String) -> [Patch] {
    var patches: [Patch] = []

    // Build lookup for old attributes
    var oldMap: [String: String] = [:]
    for (key, value) in old.pairs { oldMap[key] = value }

    var newMap: [String: String] = [:]
    for (key, value) in new.pairs { newMap[key] = value }

    // Changed or added attributes
    for (key, newValue) in newMap {
        if key == "id" { continue } // ID never changes
        if oldMap[key] != newValue {
            patches.append(Patch(op: "attr", target: "#\(id)", value: newValue, attr: key))
        }
    }

    // Removed attributes
    for key in oldMap.keys {
        if key == "id" { continue }
        if newMap[key] == nil {
            patches.append(Patch(op: "removeAttr", target: "#\(id)", attr: key))
        }
    }

    return patches
}

/// Diff two flat child lists using ID-based matching for elements
/// and positional matching for text nodes.
private func diffChildLists(old: [VNode], new: [VNode], parentId: String) -> [Patch] {
    // Text nodes have no IDs so they can only be patched positionally.
    // If a text node swaps position with an element (or is added/removed),
    // fall back to replacing the parent's inner HTML.
    for i in 0..<max(old.count, new.count) {
        var oldIsText = false
        var newIsText = false
        if i < old.count, case .text = old[i] { oldIsText = true }
        if i < new.count, case .text = new[i] { newIsText = true }
        if oldIsText != newIsText {
            let innerHTML = new.map { $0.toHTML() }.joined(separator: "\n")
            return [Patch(op: "replaceInner", target: "#\(parentId)", html: innerHTML)]
        }
    }

    // Build ID maps for element children
    var oldIdMap: [String: (index: Int, node: ElementNode)] = [:]
    for (i, node) in old.enumerated() {
        if case .element(let el) = node, !el.id.isEmpty {
            oldIdMap[el.id] = (i, el)
        }
    }

    var newIdMap: [String: (index: Int, node: ElementNode)] = [:]
    for (i, node) in new.enumerated() {
        if case .element(let el) = node, !el.id.isEmpty {
            newIdMap[el.id] = (i, el)
        }
    }

    var patches: [Patch] = []

    // Removed elements: in old but not in new
    for (id, _) in oldIdMap {
        if newIdMap[id] == nil {
            patches.append(Patch(op: "remove", target: "#\(id)"))
        }
    }

    // Process new children in order
    for (newIdx, newNode) in new.enumerated() {
        switch newNode {
        case .element(let newEl) where !newEl.id.isEmpty:
            if let oldEntry = oldIdMap[newEl.id] {
                // Element exists in both — recurse to diff it
                patches.append(contentsOf: diffElements(old: oldEntry.node, new: newEl))
            } else {
                // New element — insert it
                let html = VNode.element(newEl).toHTML()
                // Find the next sibling that exists in old tree to use as anchor
                let beforeId = findNextExistingSibling(after: newIdx, in: new, existingIds: oldIdMap)
                if let beforeId {
                    patches.append(Patch(op: "insertBefore", target: "#\(parentId)", html: html, beforeId: beforeId))
                } else {
                    patches.append(Patch(op: "append", target: "#\(parentId)", html: html))
                }
            }

        case .text(let newText):
            // Pre-check guarantees old[newIdx] is also .text
            if case .text(let oldText) = old[newIdx], oldText != newText {
                if old.count == 1 && new.count == 1 {
                    patches.append(Patch(op: "text", target: "#\(parentId)", value: newText))
                } else {
                    let innerHTML = new.map { $0.toHTML() }.joined(separator: "\n")
                    patches.append(Patch(op: "replaceInner", target: "#\(parentId)", html: innerHTML))
                    return patches
                }
            }

        default:
            // Fragment or empty-id element — skip (fragments are flattened)
            break
        }
    }

    return patches
}

/// Find the next sibling element ID that exists in the old tree, for insertBefore anchoring.
private func findNextExistingSibling(after index: Int, in nodes: [VNode], existingIds: [String: (index: Int, node: ElementNode)]) -> String? {
    for i in (index + 1)..<nodes.count {
        if case .element(let el) = nodes[i], !el.id.isEmpty, existingIds[el.id] != nil {
            return el.id
        }
    }
    return nil
}
