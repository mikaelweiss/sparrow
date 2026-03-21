public struct ZIndexModifier: ViewModifier, Sendable {
    public let zIndex: Double

    public var inlineStyles: [String: String] {
        ["z-index": "\(Int(zIndex))"]
    }
}

public enum ContentMode: Sendable {
    case fit
    case fill
}

public struct AspectRatioModifier: ViewModifier, Sendable {
    public let ratio: Double
    public let contentMode: ContentMode
    public var createsLayer: Bool { true }

    public var inlineStyles: [String: String] {
        var styles: [String: String] = ["aspect-ratio": "\(ratio)"]
        switch contentMode {
        case .fit: styles["object-fit"] = "contain"
        case .fill: styles["object-fit"] = "cover"
        }
        return styles
    }
}

public struct FixedSizeModifier: ViewModifier, Sendable {
    public let horizontal: Bool
    public let vertical: Bool

    public var inlineStyles: [String: String] {
        var styles: [String: String] = [:]
        if horizontal { styles["flex-shrink"] = "0" }
        if vertical { styles["flex-shrink"] = "0" }
        return styles
    }
}

public struct LayoutPriorityModifier: ViewModifier, Sendable {
    public let priority: Double

    public var inlineStyles: [String: String] {
        ["flex-grow": "\(priority)", "order": "\(-Int(priority))"]
    }
}

public struct PositionModifier: ViewModifier, Sendable {
    public let x: Double
    public let y: Double
    public var createsLayer: Bool { true }

    public var inlineStyles: [String: String] {
        ["position": "absolute", "left": "\(x)px", "top": "\(y)px"]
    }
}

extension View {
    public func zIndex(_ value: Double) -> ModifiedView<Self, ZIndexModifier> {
        modifier(ZIndexModifier(zIndex: value))
    }

    public func aspectRatio(_ ratio: Double, contentMode: ContentMode = .fit) -> ModifiedView<Self, AspectRatioModifier> {
        modifier(AspectRatioModifier(ratio: ratio, contentMode: contentMode))
    }

    public func fixedSize(horizontal: Bool = true, vertical: Bool = true) -> ModifiedView<Self, FixedSizeModifier> {
        modifier(FixedSizeModifier(horizontal: horizontal, vertical: vertical))
    }

    public func layoutPriority(_ value: Double) -> ModifiedView<Self, LayoutPriorityModifier> {
        modifier(LayoutPriorityModifier(priority: value))
    }

    public func position(x: Double = 0, y: Double = 0) -> ModifiedView<Self, PositionModifier> {
        modifier(PositionModifier(x: x, y: y))
    }
}
