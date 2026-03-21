public struct SheetModifier: ViewModifier, EventModifying, Sendable {
    public let isPresented: Bool
    public let onDismiss: (@Sendable () -> Void)?

    public var cssClasses: [String] {
        isPresented ? ["sheet", "sheet-active"] : ["sheet"]
    }

    public var createsLayer: Bool { true }

    public var htmlAttributes: [String: String] {
        ["data-sparrow-sheet": isPresented ? "open" : "closed"]
    }

    public var eventAttributes: [String: String] {
        onDismiss != nil ? ["data-sparrow-event": "dismiss"] : [:]
    }

    func registerEvents(id: String, with state: RenderState) {
        if let onDismiss {
            state.registerHandler(id: id, handler: onDismiss)
        }
    }
}

extension View {
    public func sheet(isPresented: Bool, onDismiss: (@Sendable () -> Void)? = nil) -> ModifiedView<Self, SheetModifier> {
        modifier(SheetModifier(isPresented: isPresented, onDismiss: onDismiss))
    }
}

public struct AlertModifier: ViewModifier, Sendable {
    public let title: String
    public let message: String
    public let isPresented: Bool

    public var htmlAttributes: [String: String] {
        isPresented
            ? ["data-sparrow-alert": "open", "data-sparrow-alert-title": title, "data-sparrow-alert-message": message]
            : [:]
    }
}

extension View {
    public func alert(_ title: String, message: String, isPresented: Bool) -> ModifiedView<Self, AlertModifier> {
        modifier(AlertModifier(title: title, message: message, isPresented: isPresented))
    }
}

public struct ConfirmationDialogModifier: ViewModifier, Sendable {
    public let title: String
    public let isPresented: Bool

    public var htmlAttributes: [String: String] {
        isPresented
            ? ["data-sparrow-dialog": "open", "data-sparrow-dialog-title": title]
            : [:]
    }
}

extension View {
    public func confirmationDialog(_ title: String, isPresented: Bool) -> ModifiedView<Self, ConfirmationDialogModifier> {
        modifier(ConfirmationDialogModifier(title: title, isPresented: isPresented))
    }
}

public struct FullScreenCoverModifier: ViewModifier, Sendable {
    public let isPresented: Bool

    public var cssClasses: [String] {
        isPresented ? ["fullscreen-cover", "fullscreen-cover-active"] : ["fullscreen-cover"]
    }

    public var createsLayer: Bool { true }

    public var htmlAttributes: [String: String] {
        ["data-sparrow-fullscreen": isPresented ? "open" : "closed"]
    }
}

extension View {
    public func fullScreenCover(isPresented: Bool) -> ModifiedView<Self, FullScreenCoverModifier> {
        modifier(FullScreenCoverModifier(isPresented: isPresented))
    }
}

public struct PopoverModifier: ViewModifier, Sendable {
    public let isPresented: Bool

    public var cssClasses: [String] {
        isPresented ? ["popover", "popover-active"] : ["popover"]
    }

    public var createsLayer: Bool { true }

    public var htmlAttributes: [String: String] {
        ["data-sparrow-popover": isPresented ? "open" : "closed"]
    }
}

extension View {
    public func popover(isPresented: Bool) -> ModifiedView<Self, PopoverModifier> {
        modifier(PopoverModifier(isPresented: isPresented))
    }
}
