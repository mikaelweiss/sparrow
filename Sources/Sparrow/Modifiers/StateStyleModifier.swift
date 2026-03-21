/// A style property that can be applied conditionally via pseudo-class selectors.
public enum StyleProperty: Sendable {
    case background(SemanticColor)
    case foreground(SemanticColor)
    case opacity(Double)
    case borderColor(SemanticColor)
    case scale(Double)
    case translateY(Double)
    case rotate(Double)

    func cssDeclaration() -> String {
        switch self {
        case .background(let color): return "background: \(color.resolvedCSSValue(forForeground: false))"
        case .foreground(let color): return "color: \(color.resolvedCSSValue(forForeground: true))"
        case .opacity(let v): return "opacity: \(v)"
        case .borderColor(let color): return "border-color: \(color.resolvedCSSValue(forForeground: false))"
        case .scale(let s): return "transform: scale(\(s))"
        case .translateY(let y): return "transform: translateY(\(y)px)"
        case .rotate(let deg): return "transform: rotate(\(deg)deg)"
        }
    }
}

/// CSS pseudo-class selectors for conditional styling.
public enum StateCondition: Sendable {
    case hover
    case focusVisible
    case focus
    case active
    case disabled
    case checked
    case dataState(String)

    var selector: String {
        switch self {
        case .hover: return ":hover"
        case .focusVisible: return ":focus-visible"
        case .focus: return ":focus"
        case .active: return ":active"
        case .disabled: return ":disabled"
        case .checked: return ":checked"
        case .dataState(let value): return "[data-state=\"\(value)\"]"
        }
    }
}

/// Generates a scoped CSS rule for pseudo-class styling.
public struct StateStyleModifier: ViewModifier, Sendable {
    public let condition: StateCondition
    public let properties: [StyleProperty]

    public var cssClasses: [String] { [] }
    public var inlineStyles: [String: String] { [:] }
    public var dataAttributes: [String: String] { [:] }
    public var htmlAttributes: [String: String] { [:] }

    func scopedCSS(for elementId: String) -> String {
        let declarations = properties.map { $0.cssDeclaration() }.joined(separator: "; ")
        return "#\(elementId)\(condition.selector) { \(declarations); }"
    }
}

extension View {
    public func hoverStyle(_ properties: StyleProperty...) -> ModifiedView<Self, StateStyleModifier> {
        modifier(StateStyleModifier(condition: .hover, properties: properties))
    }

    public func focusVisibleStyle(_ properties: StyleProperty...) -> ModifiedView<Self, StateStyleModifier> {
        modifier(StateStyleModifier(condition: .focusVisible, properties: properties))
    }

    public func activeStyle(_ properties: StyleProperty...) -> ModifiedView<Self, StateStyleModifier> {
        modifier(StateStyleModifier(condition: .active, properties: properties))
    }

    public func disabledStyle(_ properties: StyleProperty...) -> ModifiedView<Self, StateStyleModifier> {
        modifier(StateStyleModifier(condition: .disabled, properties: properties))
    }

    public func stateStyle(_ condition: StateCondition, _ properties: StyleProperty...) -> ModifiedView<Self, StateStyleModifier> {
        modifier(StateStyleModifier(condition: condition, properties: properties))
    }
}
