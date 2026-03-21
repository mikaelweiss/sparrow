/// A virtual DOM node representing a rendered HTML element.
/// Used for diffing old vs new render output to produce targeted patches.
public enum VNode: Sendable, Equatable {
    case element(ElementNode)
    case text(String)
    case fragment([VNode])
}

public struct ElementNode: Sendable, Equatable {
    public let tag: String
    public let id: String
    public var attributes: OrderedAttributes
    public var children: [VNode]

    public init(tag: String, id: String, attributes: OrderedAttributes = OrderedAttributes(), children: [VNode] = []) {
        self.tag = tag
        self.id = id
        self.attributes = attributes
        self.children = children
    }
}

/// Ordered key-value pairs for HTML attributes. Array-backed so attribute order is stable.
public struct OrderedAttributes: Sendable, Equatable {
    public var pairs: [(key: String, value: String)]

    public init(_ pairs: [(key: String, value: String)] = []) {
        self.pairs = pairs
    }

    public subscript(_ key: String) -> String? {
        get { pairs.first(where: { $0.key == key })?.value }
        set {
            if let newValue {
                if let idx = pairs.firstIndex(where: { $0.key == key }) {
                    pairs[idx] = (key, newValue)
                } else {
                    pairs.append((key, newValue))
                }
            } else {
                pairs.removeAll(where: { $0.key == key })
            }
        }
    }

    public static func == (lhs: OrderedAttributes, rhs: OrderedAttributes) -> Bool {
        guard lhs.pairs.count == rhs.pairs.count else { return false }
        for (l, r) in zip(lhs.pairs, rhs.pairs) {
            if l.key != r.key || l.value != r.value { return false }
        }
        return true
    }
}

// MARK: - Self-closing tags

private let selfClosingTags: Set<String> = [
    "area", "base", "br", "col", "embed", "hr", "img", "input",
    "link", "meta", "param", "source", "track", "wbr",
]

// MARK: - VNode → HTML serialization

extension VNode {
    public func toHTML() -> String {
        var out = ""
        writeHTML(to: &out)
        return out
    }

    func writeHTML(to out: inout String) {
        switch self {
        case .text(let str):
            out += str
        case .fragment(let nodes):
            for (i, node) in nodes.enumerated() {
                if i > 0 { out += "\n" }
                node.writeHTML(to: &out)
            }
        case .element(let el):
            out += "<"
            out += el.tag
            for (key, value) in el.attributes.pairs {
                out += " "
                out += key
                out += "=\""
                out += value
                out += "\""
            }
            if selfClosingTags.contains(el.tag) {
                out += ">"
                return
            }
            out += ">"
            for (i, child) in el.children.enumerated() {
                if i == 0 { out += "\n" }
                child.writeHTML(to: &out)
                if i < el.children.count - 1 { out += "\n" }
            }
            if !el.children.isEmpty { out += "\n" }
            out += "</"
            out += el.tag
            out += ">"
        }
    }
}

// MARK: - Helpers for building VNodes

extension ElementNode {
    static func build(
        tag: String,
        id: String,
        classes: [String] = [],
        styles: [String: String] = [:],
        extraAttrs: [(key: String, value: String)] = [],
        children: [VNode] = []
    ) -> ElementNode {
        var attrs = OrderedAttributes()
        if !id.isEmpty { attrs["id"] = id }
        if !classes.isEmpty {
            attrs["class"] = classes.joined(separator: " ")
        }
        if !styles.isEmpty {
            attrs["style"] = styles.map { "\($0.key): \($0.value)" }.joined(separator: "; ")
        }
        for (key, value) in extraAttrs {
            attrs[key] = value
        }
        return ElementNode(tag: tag, id: id, attributes: attrs, children: children)
    }
}

/// Flatten fragments into a flat list of non-fragment nodes for diffing.
func flattenVNodes(_ nodes: [VNode]) -> [VNode] {
    var result: [VNode] = []
    for node in nodes {
        if case .fragment(let children) = node {
            result.append(contentsOf: flattenVNodes(children))
        } else {
            result.append(node)
        }
    }
    return result
}
