public struct OnLongPressGestureModifier: ViewModifier, EventModifying, Sendable {
    public let minimumDuration: Double
    public let action: @Sendable () -> Void
    public var createsLayer: Bool { true }

    public var eventAttributes: [String: String] {
        ["data-sparrow-event": "longpress", "data-sparrow-duration": "\(minimumDuration)"]
    }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id, handler: action)
    }
}

extension View {
    public func onLongPressGesture(minimumDuration: Double = 0.5, perform action: @escaping @Sendable () -> Void) -> ModifiedView<Self, OnLongPressGestureModifier> {
        modifier(OnLongPressGestureModifier(minimumDuration: minimumDuration, action: action))
    }
}

public struct OnDragModifier: ViewModifier, EventModifying, Sendable {
    public let action: @Sendable () -> Void
    public var createsLayer: Bool { true }
    public var eventAttributes: [String: String] { ["draggable": "true", "data-sparrow-event": "drag"] }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id, handler: action)
    }
}

extension View {
    public func onDrag(perform action: @escaping @Sendable () -> Void) -> ModifiedView<Self, OnDragModifier> {
        modifier(OnDragModifier(action: action))
    }
}

public struct OnDropModifier: ViewModifier, EventModifying, Sendable {
    public let action: @Sendable () -> Void
    public var createsLayer: Bool { true }
    public var eventAttributes: [String: String] { ["data-sparrow-event": "drop"] }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id, handler: action)
    }
}

extension View {
    public func onDrop(perform action: @escaping @Sendable () -> Void) -> ModifiedView<Self, OnDropModifier> {
        modifier(OnDropModifier(action: action))
    }
}
