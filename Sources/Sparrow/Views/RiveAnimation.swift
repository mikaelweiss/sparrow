/// Displays a Rive animation. Renders to `<canvas>` with the Rive runtime.
///
/// The Rive WASM runtime (~150KB, cached) is lazy-loaded from CDN only when
/// a RiveAnimation view is present on the page.
///
/// ```swift
/// // Simple playback
/// RiveAnimation("hero")
///     .frame(width: 300, height: 200)
///
/// // State machine with inputs
/// RiveAnimation("like-button", stateMachine: "Toggle")
///     .riveInput("isLiked", value: isLiked)
///     .onRiveEvent("liked") { isLiked = true }
///     .riveFit(.cover)
/// ```
public struct RiveAnimation: PrimitiveView, Sendable {
    let source: Source
    let stateMachine: String?
    let artboard: String?
    let fit: RiveFit
    let autoplay: Bool
    let inputs: [String: RiveInputValue]
    let eventHandlers: [String: @Sendable () -> Void]

    public init(_ name: String, stateMachine: String? = nil) {
        self.source = .asset(name)
        self.stateMachine = stateMachine
        self.artboard = nil
        self.fit = .contain
        self.autoplay = true
        self.inputs = [:]
        self.eventHandlers = [:]
    }

    public init(url: String, stateMachine: String? = nil) {
        self.source = .url(url)
        self.stateMachine = stateMachine
        self.artboard = nil
        self.fit = .contain
        self.autoplay = true
        self.inputs = [:]
        self.eventHandlers = [:]
    }

    private init(
        source: Source,
        stateMachine: String?,
        artboard: String?,
        fit: RiveFit,
        autoplay: Bool,
        inputs: [String: RiveInputValue],
        eventHandlers: [String: @Sendable () -> Void]
    ) {
        self.source = source
        self.stateMachine = stateMachine
        self.artboard = artboard
        self.fit = fit
        self.autoplay = autoplay
        self.inputs = inputs
        self.eventHandlers = eventHandlers
    }

    // MARK: - Builder methods

    /// Set a boolean input on the state machine.
    public func riveInput(_ name: String, value: Bool) -> RiveAnimation {
        var newInputs = inputs
        newInputs[name] = .bool(value)
        return RiveAnimation(source: source, stateMachine: stateMachine, artboard: artboard, fit: fit, autoplay: autoplay, inputs: newInputs, eventHandlers: eventHandlers)
    }

    /// Set a numeric input on the state machine.
    public func riveInput(_ name: String, value: Double) -> RiveAnimation {
        var newInputs = inputs
        newInputs[name] = .number(value)
        return RiveAnimation(source: source, stateMachine: stateMachine, artboard: artboard, fit: fit, autoplay: autoplay, inputs: newInputs, eventHandlers: eventHandlers)
    }

    /// Fire a trigger input on the state machine.
    public func riveTrigger(_ name: String) -> RiveAnimation {
        var newInputs = inputs
        newInputs[name] = .trigger
        return RiveAnimation(source: source, stateMachine: stateMachine, artboard: artboard, fit: fit, autoplay: autoplay, inputs: newInputs, eventHandlers: eventHandlers)
    }

    /// Handle a Rive Event fired from the animation file.
    public func onRiveEvent(_ name: String, perform action: @escaping @Sendable () -> Void) -> RiveAnimation {
        var newHandlers = eventHandlers
        newHandlers[name] = action
        return RiveAnimation(source: source, stateMachine: stateMachine, artboard: artboard, fit: fit, autoplay: autoplay, inputs: inputs, eventHandlers: newHandlers)
    }

    /// Set how the animation fits within its container.
    public func riveFit(_ fit: RiveFit) -> RiveAnimation {
        RiveAnimation(source: source, stateMachine: stateMachine, artboard: artboard, fit: fit, autoplay: autoplay, inputs: inputs, eventHandlers: eventHandlers)
    }

    /// Select a specific artboard from the Rive file.
    public func artboard(_ name: String) -> RiveAnimation {
        RiveAnimation(source: source, stateMachine: stateMachine, artboard: name, fit: fit, autoplay: autoplay, inputs: inputs, eventHandlers: eventHandlers)
    }

    /// Control whether the animation plays automatically.
    public func autoplay(_ enabled: Bool) -> RiveAnimation {
        RiveAnimation(source: source, stateMachine: stateMachine, artboard: artboard, fit: fit, autoplay: enabled, inputs: inputs, eventHandlers: eventHandlers)
    }

    // MARK: - Types

    public enum Source: Sendable {
        case asset(String)
        case url(String)
    }
}

public enum RiveFit: String, Sendable {
    case contain
    case cover
    case fill
    case fitWidth
    case fitHeight
    case none
    case scaleDown
}

public enum RiveInputValue: Sendable {
    case bool(Bool)
    case number(Double)
    case trigger
}
