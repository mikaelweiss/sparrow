/// Displays a Lottie animation. Renders to a `<div>` with the lottie-web player.
///
/// The lottie-web library (~250KB, cached) is lazy-loaded from CDN only when
/// a LottieAnimation view is present on the page.
///
/// ```swift
/// // Simple playback
/// LottieAnimation("loading-spinner")
///     .looping()
///     .frame(width: 200, height: 200)
///
/// // Custom speed and direction
/// LottieAnimation(url: "https://example.com/animation.json")
///     .speed(1.5)
///     .direction(.reverse)
///     .onComplete { handleDone() }
/// ```
public struct LottieAnimation: PrimitiveView, Sendable {
    let source: Source
    let loop: Bool
    let autoplay: Bool
    let speed: Double
    let direction: LottieDirection
    let renderer: LottieRenderer
    let onCompleteHandler: (@Sendable () -> Void)?
    let onLoopCompleteHandler: (@Sendable () -> Void)?

    public init(_ name: String) {
        self.source = .asset(name)
        self.loop = false
        self.autoplay = true
        self.speed = 1.0
        self.direction = .forward
        self.renderer = .svg
        self.onCompleteHandler = nil
        self.onLoopCompleteHandler = nil
    }

    public init(url: String) {
        self.source = .url(url)
        self.loop = false
        self.autoplay = true
        self.speed = 1.0
        self.direction = .forward
        self.renderer = .svg
        self.onCompleteHandler = nil
        self.onLoopCompleteHandler = nil
    }

    private init(
        source: Source,
        loop: Bool,
        autoplay: Bool,
        speed: Double,
        direction: LottieDirection,
        renderer: LottieRenderer,
        onCompleteHandler: (@Sendable () -> Void)?,
        onLoopCompleteHandler: (@Sendable () -> Void)?
    ) {
        self.source = source
        self.loop = loop
        self.autoplay = autoplay
        self.speed = speed
        self.direction = direction
        self.renderer = renderer
        self.onCompleteHandler = onCompleteHandler
        self.onLoopCompleteHandler = onLoopCompleteHandler
    }

    // MARK: - Builder methods

    /// Loop the animation continuously.
    public func looping(_ enabled: Bool = true) -> LottieAnimation {
        LottieAnimation(source: source, loop: enabled, autoplay: autoplay, speed: speed, direction: direction, renderer: renderer, onCompleteHandler: onCompleteHandler, onLoopCompleteHandler: onLoopCompleteHandler)
    }

    /// Set the playback speed (1.0 = normal, 2.0 = double speed).
    public func speed(_ speed: Double) -> LottieAnimation {
        LottieAnimation(source: source, loop: loop, autoplay: autoplay, speed: speed, direction: direction, renderer: renderer, onCompleteHandler: onCompleteHandler, onLoopCompleteHandler: onLoopCompleteHandler)
    }

    /// Control whether the animation plays automatically.
    public func autoplay(_ enabled: Bool) -> LottieAnimation {
        LottieAnimation(source: source, loop: loop, autoplay: enabled, speed: speed, direction: direction, renderer: renderer, onCompleteHandler: onCompleteHandler, onLoopCompleteHandler: onLoopCompleteHandler)
    }

    /// Set the playback direction.
    public func direction(_ direction: LottieDirection) -> LottieAnimation {
        LottieAnimation(source: source, loop: loop, autoplay: autoplay, speed: speed, direction: direction, renderer: renderer, onCompleteHandler: onCompleteHandler, onLoopCompleteHandler: onLoopCompleteHandler)
    }

    /// Choose the Lottie rendering backend.
    public func lottieRenderer(_ renderer: LottieRenderer) -> LottieAnimation {
        LottieAnimation(source: source, loop: loop, autoplay: autoplay, speed: speed, direction: direction, renderer: renderer, onCompleteHandler: onCompleteHandler, onLoopCompleteHandler: onLoopCompleteHandler)
    }

    /// Called when a non-looping animation completes.
    public func onComplete(_ handler: @escaping @Sendable () -> Void) -> LottieAnimation {
        LottieAnimation(source: source, loop: loop, autoplay: autoplay, speed: speed, direction: direction, renderer: renderer, onCompleteHandler: handler, onLoopCompleteHandler: onLoopCompleteHandler)
    }

    /// Called each time a looping animation completes one cycle.
    public func onLoopComplete(_ handler: @escaping @Sendable () -> Void) -> LottieAnimation {
        LottieAnimation(source: source, loop: loop, autoplay: autoplay, speed: speed, direction: direction, renderer: renderer, onCompleteHandler: onCompleteHandler, onLoopCompleteHandler: handler)
    }

    // MARK: - Types

    public enum Source: Sendable {
        case asset(String)
        case url(String)
    }
}

public enum LottieDirection: Int, Sendable {
    case forward = 1
    case reverse = -1
}

public enum LottieRenderer: String, Sendable {
    case svg
    case canvas
}
