public struct TintModifier: ViewModifier, Sendable {
    public let color: SemanticColor

    public var cssClasses: [String] {
        color.needsInlineStyle ? [] : ["tint-\(color.cssValue)"]
    }

    public var inlineStyles: [String: String] {
        color.needsInlineStyle ? ["--tint": color.resolvedCSSValue(forForeground: true)] : [:]
    }
}

public enum ColorScheme: Sendable {
    case light, dark
}

public struct PreferredColorSchemeModifier: ViewModifier, Sendable {
    public let scheme: ColorScheme

    public var inlineStyles: [String: String] {
        ["color-scheme": scheme == .light ? "light" : "dark"]
    }
}

public struct TagModifier: ViewModifier, Sendable {
    public let tag: String
    public var htmlAttributes: [String: String] { ["data-tag": tag] }
}

public enum ButtonStyleType: Sendable {
    case automatic, bordered, borderedProminent, borderless, plain

    var cssClass: String {
        switch self {
        case .automatic: "btn-auto"
        case .bordered: "btn-bordered"
        case .borderedProminent: "btn-bordered-prominent"
        case .borderless: "btn-borderless"
        case .plain: "btn-plain"
        }
    }
}

public struct ButtonStyleModifier: ViewModifier, Sendable {
    public let style: ButtonStyleType
    public var cssClasses: [String] { [style.cssClass] }
}

public enum PickerStyleType: Sendable {
    case automatic, menu, segmented, wheel, inline

    var cssClass: String {
        switch self {
        case .automatic: "picker-auto"
        case .menu: "picker-menu"
        case .segmented: "picker-segmented"
        case .wheel: "picker-wheel"
        case .inline: "picker-inline"
        }
    }
}

public struct PickerStyleModifier: ViewModifier, Sendable {
    public let style: PickerStyleType
    public var cssClasses: [String] { [style.cssClass] }
}

public enum ToggleStyleType: Sendable {
    case automatic, `switch`, button, checkbox

    var cssClass: String {
        switch self {
        case .automatic: "toggle-auto"
        case .switch: "toggle-switch"
        case .button: "toggle-button"
        case .checkbox: "toggle-checkbox"
        }
    }
}

public struct ToggleStyleModifier: ViewModifier, Sendable {
    public let style: ToggleStyleType
    public var cssClasses: [String] { [style.cssClass] }
}

public enum ProgressViewStyleType: Sendable {
    case automatic, linear, circular

    var cssClass: String {
        switch self {
        case .automatic: "progress-auto"
        case .linear: "progress-linear"
        case .circular: "progress-circular"
        }
    }
}

public struct ProgressViewStyleModifier: ViewModifier, Sendable {
    public let style: ProgressViewStyleType
    public var cssClasses: [String] { [style.cssClass] }
}

public enum DatePickerStyleType: Sendable {
    case automatic, compact, graphical, wheel

    var cssClass: String {
        switch self {
        case .automatic: "datepicker-auto"
        case .compact: "datepicker-compact"
        case .graphical: "datepicker-graphical"
        case .wheel: "datepicker-wheel"
        }
    }
}

public struct DatePickerStyleModifier: ViewModifier, Sendable {
    public let style: DatePickerStyleType
    public var cssClasses: [String] { [style.cssClass] }
}

extension View {
    public func tint(_ color: SemanticColor) -> ModifiedView<Self, TintModifier> {
        modifier(TintModifier(color: color))
    }

    public func preferredColorScheme(_ scheme: ColorScheme) -> ModifiedView<Self, PreferredColorSchemeModifier> {
        modifier(PreferredColorSchemeModifier(scheme: scheme))
    }

    public func tag(_ tag: String) -> ModifiedView<Self, TagModifier> {
        modifier(TagModifier(tag: tag))
    }

    public func buttonStyle(_ style: ButtonStyleType) -> ModifiedView<Self, ButtonStyleModifier> {
        modifier(ButtonStyleModifier(style: style))
    }

    public func pickerStyle(_ style: PickerStyleType) -> ModifiedView<Self, PickerStyleModifier> {
        modifier(PickerStyleModifier(style: style))
    }

    public func toggleStyle(_ style: ToggleStyleType) -> ModifiedView<Self, ToggleStyleModifier> {
        modifier(ToggleStyleModifier(style: style))
    }

    public func progressViewStyle(_ style: ProgressViewStyleType) -> ModifiedView<Self, ProgressViewStyleModifier> {
        modifier(ProgressViewStyleModifier(style: style))
    }

    public func datePickerStyle(_ style: DatePickerStyleType) -> ModifiedView<Self, DatePickerStyleModifier> {
        modifier(DatePickerStyleModifier(style: style))
    }
}
