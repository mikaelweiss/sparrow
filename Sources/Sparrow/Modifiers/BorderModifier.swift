public struct BorderModifier: ViewModifier, Sendable {
    public let color: SemanticColor
    public let width: Int
    public var createsLayer: Bool { true }

    public var cssClasses: [String] {
        color.needsInlineStyle ? ["border"] : ["border", "border-\(color.cssValue)"]
    }

    public var inlineStyles: [String: String] {
        if color.needsInlineStyle {
            return [
                "border-width": "\(width)px",
                "border-color": color.resolvedCSSValue(forForeground: false),
                "border-style": "solid",
            ]
        }
        return ["border-width": "\(width)px"]
    }
}

extension View {
    public func border(_ color: SemanticColor, width: Int = 1) -> ModifiedView<Self, BorderModifier> {
        modifier(BorderModifier(color: color, width: width))
    }
}
