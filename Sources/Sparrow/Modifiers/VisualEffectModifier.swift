public struct BlurModifier: ViewModifier, Sendable {
    public let radius: Double

    public var inlineStyles: [String: String] {
        ["filter": "blur(\(radius)px)"]
    }
}

public struct GrayscaleModifier: ViewModifier, Sendable {
    public let amount: Double

    public var inlineStyles: [String: String] {
        ["filter": "grayscale(\(amount))"]
    }
}

/// SwiftUI brightness ranges from -1 to 1 (0 = unchanged).
/// CSS brightness is a multiplier (1 = unchanged), so we add 1.
public struct BrightnessModifier: ViewModifier, Sendable {
    public let amount: Double

    public var inlineStyles: [String: String] {
        ["filter": "brightness(\(1 + amount))"]
    }
}

public struct ContrastModifier: ViewModifier, Sendable {
    public let amount: Double

    public var inlineStyles: [String: String] {
        ["filter": "contrast(\(amount))"]
    }
}

public struct SaturationModifier: ViewModifier, Sendable {
    public let amount: Double

    public var inlineStyles: [String: String] {
        ["filter": "saturate(\(amount))"]
    }
}

public struct HueRotationModifier: ViewModifier, Sendable {
    public let angle: Double

    public var inlineStyles: [String: String] {
        ["filter": "hue-rotate(\(angle)deg)"]
    }
}

public struct ColorInvertModifier: ViewModifier, Sendable {
    public var inlineStyles: [String: String] {
        ["filter": "invert(1)"]
    }
}

public enum BlendMode: String, Sendable {
    case normal
    case multiply
    case screen
    case overlay
    case darken
    case lighten
    case colorDodge
    case colorBurn
    case softLight
    case hardLight
    case difference
    case exclusion
    case hue
    case saturation
    case color
    case luminosity

    var cssValue: String {
        switch self {
        case .colorDodge: "color-dodge"
        case .colorBurn: "color-burn"
        case .softLight: "soft-light"
        case .hardLight: "hard-light"
        default: rawValue
        }
    }
}

public struct BlendModeModifier: ViewModifier, Sendable {
    public let mode: BlendMode

    public var inlineStyles: [String: String] {
        ["mix-blend-mode": mode.cssValue]
    }
}

public struct CompositingGroupModifier: ViewModifier, Sendable {
    public var createsLayer: Bool { true }

    public var inlineStyles: [String: String] {
        ["isolation": "isolate"]
    }
}

extension View {
    public func blur(radius: Double) -> ModifiedView<Self, BlurModifier> {
        modifier(BlurModifier(radius: radius))
    }

    public func grayscale(_ amount: Double) -> ModifiedView<Self, GrayscaleModifier> {
        modifier(GrayscaleModifier(amount: amount))
    }

    public func brightness(_ amount: Double) -> ModifiedView<Self, BrightnessModifier> {
        modifier(BrightnessModifier(amount: amount))
    }

    public func contrast(_ amount: Double) -> ModifiedView<Self, ContrastModifier> {
        modifier(ContrastModifier(amount: amount))
    }

    public func saturation(_ amount: Double) -> ModifiedView<Self, SaturationModifier> {
        modifier(SaturationModifier(amount: amount))
    }

    public func hueRotation(_ angle: Double) -> ModifiedView<Self, HueRotationModifier> {
        modifier(HueRotationModifier(angle: angle))
    }

    public func colorInvert() -> ModifiedView<Self, ColorInvertModifier> {
        modifier(ColorInvertModifier())
    }

    public func blendMode(_ mode: BlendMode) -> ModifiedView<Self, BlendModeModifier> {
        modifier(BlendModeModifier(mode: mode))
    }

    public func compositingGroup() -> ModifiedView<Self, CompositingGroupModifier> {
        modifier(CompositingGroupModifier())
    }
}
