public struct ResizableModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["img-resizable"] }
}

extension View {
    public func resizable() -> ModifiedView<Self, ResizableModifier> {
        modifier(ResizableModifier())
    }
}

public struct ScaledToFitModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["object-contain"] }
}

extension View {
    public func scaledToFit() -> ModifiedView<Self, ScaledToFitModifier> {
        modifier(ScaledToFitModifier())
    }
}

public struct ScaledToFillModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["object-cover"] }
}

extension View {
    public func scaledToFill() -> ModifiedView<Self, ScaledToFillModifier> {
        modifier(ScaledToFillModifier())
    }
}

public enum ImageRenderingMode: Sendable {
    case original, template
}

public struct RenderingModeModifier: ViewModifier, Sendable {
    public let mode: ImageRenderingMode

    public var cssClasses: [String] {
        switch mode {
        case .template: ["img-template"]
        case .original: []
        }
    }
}

extension View {
    public func renderingMode(_ mode: ImageRenderingMode) -> ModifiedView<Self, RenderingModeModifier> {
        modifier(RenderingModeModifier(mode: mode))
    }
}

public enum ImageInterpolation: Sendable {
    case none, low, medium, high

    var cssValue: String {
        switch self {
        case .none: "pixelated"
        case .low: "pixelated"
        case .medium: "auto"
        case .high: "auto"
        }
    }
}

public struct InterpolationModifier: ViewModifier, Sendable {
    public let interpolation: ImageInterpolation
    public var inlineStyles: [String: String] { ["image-rendering": interpolation.cssValue] }
}

extension View {
    public func interpolation(_ interpolation: ImageInterpolation) -> ModifiedView<Self, InterpolationModifier> {
        modifier(InterpolationModifier(interpolation: interpolation))
    }
}

public struct AntialiasedModifier: ViewModifier, Sendable {
    public let isAntialiased: Bool
    public var inlineStyles: [String: String] { ["image-rendering": isAntialiased ? "auto" : "pixelated"] }
}

extension View {
    public func antialiased(_ isAntialiased: Bool = true) -> ModifiedView<Self, AntialiasedModifier> {
        modifier(AntialiasedModifier(isAntialiased: isAntialiased))
    }
}
