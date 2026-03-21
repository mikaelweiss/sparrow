public enum ScrollIndicatorVisibility: Sendable {
    case automatic, visible, hidden, never
}

public struct ScrollIndicatorsModifier: ViewModifier, Sendable {
    public let visibility: ScrollIndicatorVisibility

    public var cssClasses: [String] {
        switch visibility {
        case .automatic: []
        case .visible: ["scrollbar-visible"]
        case .hidden, .never: ["scrollbar-hidden"]
        }
    }
}

public struct ScrollDisabledModifier: ViewModifier, Sendable {
    public let isDisabled: Bool
    public var createsLayer: Bool { true }

    public var cssClasses: [String] {
        isDisabled ? ["overflow-hidden"] : []
    }
}

public struct ScrollContentBackgroundModifier: ViewModifier, Sendable {
    public let visibility: Visibility

    public var cssClasses: [String] {
        switch visibility {
        case .hidden: ["scroll-bg-hidden"]
        case .automatic, .visible: []
        }
    }
}

public struct ScrollClipDisabledModifier: ViewModifier, Sendable {
    public let isDisabled: Bool
    public var createsLayer: Bool { true }

    public var cssClasses: [String] {
        isDisabled ? ["overflow-visible"] : []
    }
}

public enum ScrollBounceBehavior: Sendable {
    case automatic, always, basedOnSize
}

public struct ScrollBounceModifier: ViewModifier, Sendable {
    public let behavior: ScrollBounceBehavior

    public var cssClasses: [String] {
        switch behavior {
        case .automatic: []
        case .always: ["overscroll-contain"]
        case .basedOnSize: ["overscroll-auto"]
        }
    }
}

extension View {
    public func scrollIndicators(_ visibility: ScrollIndicatorVisibility) -> ModifiedView<Self, ScrollIndicatorsModifier> {
        modifier(ScrollIndicatorsModifier(visibility: visibility))
    }

    public func scrollDisabled(_ disabled: Bool) -> ModifiedView<Self, ScrollDisabledModifier> {
        modifier(ScrollDisabledModifier(isDisabled: disabled))
    }

    public func scrollContentBackground(_ visibility: Visibility) -> ModifiedView<Self, ScrollContentBackgroundModifier> {
        modifier(ScrollContentBackgroundModifier(visibility: visibility))
    }

    public func scrollClipDisabled(_ disabled: Bool = true) -> ModifiedView<Self, ScrollClipDisabledModifier> {
        modifier(ScrollClipDisabledModifier(isDisabled: disabled))
    }

    public func scrollBounceBehavior(_ behavior: ScrollBounceBehavior) -> ModifiedView<Self, ScrollBounceModifier> {
        modifier(ScrollBounceModifier(behavior: behavior))
    }
}
