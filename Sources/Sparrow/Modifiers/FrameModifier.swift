/// Dimension value — either a fixed pixel value or infinity (fill).
public enum Dimension: Sendable {
    case fixed(Int)
    case infinity

    var cssValue: String {
        switch self {
        case .fixed(let px): "\(px)px"
        case .infinity: "100%"
        }
    }
}

public struct FrameModifier: ViewModifier, Sendable {
    public let width: Dimension?
    public let height: Dimension?
    public let maxWidth: Dimension?
    public let minHeight: Dimension?

    public var cssClasses: [String] { [] }

    public var inlineStyles: [String: String] {
        var styles: [String: String] = [:]
        if let width { styles["width"] = width.cssValue }
        if let height { styles["height"] = height.cssValue }
        if let maxWidth { styles["max-width"] = maxWidth.cssValue }
        if let minHeight { styles["min-height"] = minHeight.cssValue }
        return styles
    }
}

extension View {
    public func frame(
        width: Int? = nil,
        height: Int? = nil
    ) -> ModifiedView<Self, FrameModifier> {
        modifier(FrameModifier(
            width: width.map { .fixed($0) },
            height: height.map { .fixed($0) },
            maxWidth: nil,
            minHeight: nil
        ))
    }

    public func frame(
        maxWidth: Dimension? = nil,
        minHeight: Dimension? = nil
    ) -> ModifiedView<Self, FrameModifier> {
        modifier(FrameModifier(
            width: nil,
            height: nil,
            maxWidth: maxWidth,
            minHeight: minHeight
        ))
    }
}
