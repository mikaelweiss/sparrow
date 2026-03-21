public enum TransitionProperty: String, Sendable {
    case all
    case colors = "color, background-color, border-color, text-decoration-color, fill, stroke"
    case opacity
    case shadow = "box-shadow"
    case transform
    case none
}

public struct TransitionPropertyModifier: ViewModifier, Sendable {
    public let property: TransitionProperty
    public let duration: Int
    public let timing: String

    public var inlineStyles: [String: String] {
        if property == .none { return ["transition": "none"] }
        return [
            "transition-property": property.rawValue,
            "transition-duration": "\(duration)ms",
            "transition-timing-function": timing
        ]
    }
}

extension View {
    public func transition(_ property: TransitionProperty, duration: Int = 150, timing: String = "cubic-bezier(0.4, 0, 0.2, 1)") -> ModifiedView<Self, TransitionPropertyModifier> {
        modifier(TransitionPropertyModifier(property: property, duration: duration, timing: timing))
    }
}
