/// Modifiers that set data attributes for client-side behavioral primitives
/// (focus traps, roving focus, floating positioning, dismissable layers).

public struct RovingFocusModifier: ViewModifier, Sendable {
    let orientation: RovingOrientation
    public var dataAttributes: [String: String] { ["data-sparrow-roving": orientation.rawValue] }
}

public enum RovingOrientation: String, Sendable { case horizontal, vertical }

public struct RovingFocusItemModifier: ViewModifier, Sendable {
    public var dataAttributes: [String: String] { ["data-sparrow-roving-item": ""] }
}

public struct FocusTrapModifier: ViewModifier, Sendable {
    public var dataAttributes: [String: String] { ["data-sparrow-focus-trap": ""] }
}

public struct DismissableModifier: ViewModifier, Sendable {
    let targetId: String
    public var dataAttributes: [String: String] { ["data-sparrow-dismissable": targetId] }
}

public struct FloatingModifier: ViewModifier, Sendable {
    let side: String
    let anchorId: String
    public var dataAttributes: [String: String] {
        ["data-sparrow-floating": side, "data-sparrow-floating-anchor": anchorId]
    }
}

public struct DataStateModifier: ViewModifier, Sendable {
    let state: String
    public var dataAttributes: [String: String] { ["data-state": state] }
}

extension View {
    public func rovingFocus(_ orientation: RovingOrientation) -> ModifiedView<Self, RovingFocusModifier> {
        modifier(RovingFocusModifier(orientation: orientation))
    }

    public func rovingFocusItem() -> ModifiedView<Self, RovingFocusItemModifier> {
        modifier(RovingFocusItemModifier())
    }

    public func focusTrap() -> ModifiedView<Self, FocusTrapModifier> {
        modifier(FocusTrapModifier())
    }

    public func dismissable(targetId: String) -> ModifiedView<Self, DismissableModifier> {
        modifier(DismissableModifier(targetId: targetId))
    }

    public func floating(side: String, anchorId: String) -> ModifiedView<Self, FloatingModifier> {
        modifier(FloatingModifier(side: side, anchorId: anchorId))
    }

    public func dataState(_ state: String) -> ModifiedView<Self, DataStateModifier> {
        modifier(DataStateModifier(state: state))
    }
}
