public enum BorderEdge: Sendable {
    case all, top, bottom, leading, trailing
}

public struct BorderModifier: ViewModifier, Sendable {
    public let color: SemanticColor
    public let width: Int
    public let edge: BorderEdge
    public var createsLayer: Bool { true }

    public var cssClasses: [String] {
        color.needsInlineStyle ? ["border"] : ["border", "border-\(color.cssValue)"]
    }

    public var inlineStyles: [String: String] {
        let borderProp: String
        switch edge {
        case .all: borderProp = "border"
        case .top: borderProp = "border-top"
        case .bottom: borderProp = "border-bottom"
        case .leading: borderProp = "border-left"
        case .trailing: borderProp = "border-right"
        }
        if color.needsInlineStyle {
            return [
                "\(borderProp)-width": "\(width)px",
                "\(borderProp)-color": color.resolvedCSSValue(forForeground: false),
                "\(borderProp)-style": "solid",
            ]
        }
        if edge == .all {
            return ["border-width": "\(width)px"]
        }
        return [
            "\(borderProp)-width": "\(width)px",
            "\(borderProp)-style": "solid",
        ]
    }
}

extension View {
    public func border(_ color: SemanticColor, width: Int = 1) -> ModifiedView<Self, BorderModifier> {
        modifier(BorderModifier(color: color, width: width, edge: .all))
    }

    public func border(_ color: SemanticColor, width: Int = 1, edge: BorderEdge) -> ModifiedView<Self, BorderModifier> {
        modifier(BorderModifier(color: color, width: width, edge: edge))
    }
}
