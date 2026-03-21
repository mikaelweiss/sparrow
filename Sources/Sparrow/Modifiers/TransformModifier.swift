public struct RotationModifier: ViewModifier, Sendable {
    public let angle: Double

    public var inlineStyles: [String: String] {
        ["transform": "rotate(\(angle)deg)"]
    }
}

public struct ScaleModifier: ViewModifier, Sendable {
    public let x: Double
    public let y: Double

    public var inlineStyles: [String: String] {
        ["transform": "scale(\(x), \(y))"]
    }
}

public struct OffsetModifier: ViewModifier, Sendable {
    public let x: Double
    public let y: Double

    public var inlineStyles: [String: String] {
        ["transform": "translate(\(x)px, \(y)px)"]
    }
}

extension View {
    public func rotationEffect(_ angle: Double) -> ModifiedView<Self, RotationModifier> {
        modifier(RotationModifier(angle: angle))
    }

    public func scaleEffect(_ scale: Double) -> ModifiedView<Self, ScaleModifier> {
        modifier(ScaleModifier(x: scale, y: scale))
    }

    public func scaleEffect(x: Double = 1, y: Double = 1) -> ModifiedView<Self, ScaleModifier> {
        modifier(ScaleModifier(x: x, y: y))
    }

    public func offset(x: Double = 0, y: Double = 0) -> ModifiedView<Self, OffsetModifier> {
        modifier(OffsetModifier(x: x, y: y))
    }
}
