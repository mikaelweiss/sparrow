public enum Overflow: String, Sendable {
    case visible
    case hidden
    case scroll
    case auto
}

public struct OverflowModifier: ViewModifier, Sendable {
    public let x: Overflow?
    public let y: Overflow?

    public var inlineStyles: [String: String] {
        var styles: [String: String] = [:]
        if let x, let y, x == y {
            styles["overflow"] = x.rawValue
        } else {
            if let x { styles["overflow-x"] = x.rawValue }
            if let y { styles["overflow-y"] = y.rawValue }
        }
        return styles
    }
}

extension View {
    public func overflow(_ value: Overflow) -> ModifiedView<Self, OverflowModifier> {
        modifier(OverflowModifier(x: value, y: value))
    }

    public func overflow(x: Overflow? = nil, y: Overflow? = nil) -> ModifiedView<Self, OverflowModifier> {
        modifier(OverflowModifier(x: x, y: y))
    }
}
