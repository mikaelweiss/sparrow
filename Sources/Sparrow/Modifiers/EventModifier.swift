public struct OnAppearModifier: ViewModifier, EventModifying, Sendable {
    public let action: @Sendable () -> Void
    public var createsLayer: Bool { true }
    public var eventAttributes: [String: String] { ["data-sparrow-event": "appear"] }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id, handler: action)
    }
}

extension View {
    public func onAppear(perform action: @escaping @Sendable () -> Void) -> ModifiedView<Self, OnAppearModifier> {
        modifier(OnAppearModifier(action: action))
    }
}

public struct OnDisappearModifier: ViewModifier, EventModifying, Sendable {
    public let action: @Sendable () -> Void
    public var createsLayer: Bool { true }
    public var eventAttributes: [String: String] { ["data-sparrow-event": "disappear"] }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id, handler: action)
    }
}

extension View {
    public func onDisappear(perform action: @escaping @Sendable () -> Void) -> ModifiedView<Self, OnDisappearModifier> {
        modifier(OnDisappearModifier(action: action))
    }
}

public struct TaskModifier: ViewModifier, EventModifying, Sendable {
    public let action: @Sendable () async -> Void
    public var createsLayer: Bool { true }
    public var eventAttributes: [String: String] { ["data-sparrow-event": "appear"] }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id) { Task { await action() } }
    }
}

extension View {
    public func task(_ action: @escaping @Sendable () async -> Void) -> ModifiedView<Self, TaskModifier> {
        modifier(TaskModifier(action: action))
    }
}

public struct OnTapGestureModifier: ViewModifier, EventModifying, Sendable {
    public let count: Int
    public let action: @Sendable () -> Void
    public var createsLayer: Bool { true }

    public var eventAttributes: [String: String] {
        var attrs = ["data-sparrow-event": "click"]
        if count > 1 {
            attrs["data-sparrow-tap-count"] = "\(count)"
        }
        return attrs
    }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id, handler: action)
    }
}

extension View {
    public func onTapGesture(count: Int = 1, perform action: @escaping @Sendable () -> Void) -> ModifiedView<Self, OnTapGestureModifier> {
        modifier(OnTapGestureModifier(count: count, action: action))
    }
}

public struct OnSubmitModifier: ViewModifier, EventModifying, Sendable {
    public let action: @Sendable () -> Void
    public var createsLayer: Bool { true }
    public var eventAttributes: [String: String] { ["data-sparrow-event": "submit"] }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id, handler: action)
    }
}

extension View {
    public func onSubmit(_ action: @escaping @Sendable () -> Void) -> ModifiedView<Self, OnSubmitModifier> {
        modifier(OnSubmitModifier(action: action))
    }
}

public struct OnChangeModifier: ViewModifier, EventModifying, Sendable {
    public let action: @Sendable () -> Void
    public var createsLayer: Bool { true }
    public var eventAttributes: [String: String] { ["data-sparrow-event": "change"] }

    func registerEvents(id: String, with state: RenderState) {
        state.registerHandler(id: id, handler: action)
    }
}

extension View {
    public func onChange(perform action: @escaping @Sendable () -> Void) -> ModifiedView<Self, OnChangeModifier> {
        modifier(OnChangeModifier(action: action))
    }
}

public struct OnHoverModifier: ViewModifier, EventModifying, Sendable {
    public let action: @Sendable (Bool) -> Void
    public var createsLayer: Bool { true }
    public var eventAttributes: [String: String] { ["data-sparrow-event": "hover"] }

    func registerEvents(id: String, with state: RenderState) {
        state.registerValueHandler(id: id) { value in action(value == "true") }
    }
}

extension View {
    public func onHover(perform action: @escaping @Sendable (Bool) -> Void) -> ModifiedView<Self, OnHoverModifier> {
        modifier(OnHoverModifier(action: action))
    }
}
