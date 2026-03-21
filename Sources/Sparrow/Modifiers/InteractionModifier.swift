public struct DisabledModifier: ViewModifier, Sendable {
    public let isDisabled: Bool

    public var cssClasses: [String] {
        isDisabled ? ["disabled"] : []
    }

    public var htmlAttributes: [String: String] {
        isDisabled ? ["aria-disabled": "true"] : [:]
    }
}

extension View {
    public func disabled(_ disabled: Bool) -> ModifiedView<Self, DisabledModifier> {
        modifier(DisabledModifier(isDisabled: disabled))
    }
}

public enum CursorStyle: Sendable {
    case `default`, pointer, text, move, notAllowed
    case grab, grabbing, zoomIn, zoomOut
    case help, wait, crosshair, progress, copy, none

    var cssClass: String {
        switch self {
        case .default: "cursor-default"
        case .pointer: "cursor-pointer"
        case .text: "cursor-text"
        case .move: "cursor-move"
        case .notAllowed: "cursor-not-allowed"
        case .grab: "cursor-grab"
        case .grabbing: "cursor-grabbing"
        case .zoomIn: "cursor-zoom-in"
        case .zoomOut: "cursor-zoom-out"
        case .help: "cursor-help"
        case .wait: "cursor-wait"
        case .crosshair: "cursor-crosshair"
        case .progress: "cursor-progress"
        case .copy: "cursor-copy"
        case .none: "cursor-none"
        }
    }
}

public struct CursorModifier: ViewModifier, Sendable {
    public let style: CursorStyle
    public var cssClasses: [String] { [style.cssClass] }
}

extension View {
    public func cursor(_ style: CursorStyle) -> ModifiedView<Self, CursorModifier> {
        modifier(CursorModifier(style: style))
    }
}

public struct AllowsHitTestingModifier: ViewModifier, Sendable {
    public let enabled: Bool

    public var cssClasses: [String] {
        [enabled ? "pointer-events-auto" : "pointer-events-none"]
    }
}

extension View {
    public func allowsHitTesting(_ enabled: Bool) -> ModifiedView<Self, AllowsHitTestingModifier> {
        modifier(AllowsHitTestingModifier(enabled: enabled))
    }
}

public struct FocusableModifier: ViewModifier, Sendable {
    public let isFocusable: Bool
    public var htmlAttributes: [String: String] { ["tabindex": isFocusable ? "0" : "-1"] }
}

extension View {
    public func focusable(_ isFocusable: Bool = true) -> ModifiedView<Self, FocusableModifier> {
        modifier(FocusableModifier(isFocusable: isFocusable))
    }
}

public enum HoverEffect: Sendable {
    case automatic, highlight, lift

    var cssClass: String {
        switch self {
        case .automatic: "hover-auto"
        case .highlight: "hover-highlight"
        case .lift: "hover-lift"
        }
    }
}

public struct HoverEffectModifier: ViewModifier, Sendable {
    public let effect: HoverEffect
    public var cssClasses: [String] { [effect.cssClass] }
}

extension View {
    public func hoverEffect(_ effect: HoverEffect = .automatic) -> ModifiedView<Self, HoverEffectModifier> {
        modifier(HoverEffectModifier(effect: effect))
    }
}
