/// Drives a view with explicit keyframe tracks, generating CSS @keyframes
/// with per-keyframe timing functions.
///
/// Usage:
/// ```swift
/// KeyframeAnimator(initialValue: AnimState(y: 0, scale: 1)) { value in
///     Circle()
///         .offset(y: value.y)
///         .scaleEffect(value.scale)
/// } keyframes: { _ in
///     KeyframeTrack(\.y) {
///         SpringKeyframe(-50, duration: 0.3)
///         SpringKeyframe(0, duration: 0.5)
///     }
///     KeyframeTrack(\.scale) {
///         LinearKeyframe(1.2, duration: 0.3)
///         LinearKeyframe(1.0, duration: 0.5)
///     }
/// }
/// ```
///
/// Each KeyframeTrack maps to a CSS property animation. The renderer
/// computes the combined timeline and generates a single @keyframes rule.
public struct KeyframeAnimator<Value: Sendable>: View, _KeyframeAnimatorRenderable {
    public typealias Body = Never

    let initialValue: Value
    let repeating: Bool
    let content: @Sendable (Value) -> any View
    let tracks: [AnyKeyframeTrack]

    public init(
        initialValue: Value,
        repeating: Bool = true,
        @ViewBuilder content: @escaping @Sendable (Value) -> any View,
        @KeyframeTrackBuilder keyframes: () -> [AnyKeyframeTrack]
    ) {
        self.initialValue = initialValue
        self.repeating = repeating
        self.content = content
        self.tracks = keyframes()
    }

    public var body: Never { fatalError("KeyframeAnimator renders directly") }

    // MARK: - _KeyframeAnimatorRenderable

    var _tracks: [AnyKeyframeTrack] { tracks }
    var _repeating: Bool { repeating }

    func _contentForInitial() -> any View {
        content(initialValue)
    }
}

/// Internal protocol for renderer dispatch.
protocol _KeyframeAnimatorRenderable {
    var _tracks: [AnyKeyframeTrack] { get }
    var _repeating: Bool { get }
    func _contentForInitial() -> any View
}

// MARK: - Keyframe Types

/// A single keyframe with a value, duration, and timing curve.
public struct Keyframe: Sendable {
    public let cssValue: String
    public let duration: Double
    public let timingFunction: String

    init(cssValue: String, duration: Double, timingFunction: String) {
        self.cssValue = cssValue
        self.duration = duration
        self.timingFunction = timingFunction
    }
}

/// Type-erased keyframe track that produces CSS property keyframes.
public struct AnyKeyframeTrack: Sendable {
    public let cssProperty: String
    public let keyframes: [Keyframe]

    public init(cssProperty: String, keyframes: [Keyframe]) {
        self.cssProperty = cssProperty
        self.keyframes = keyframes
    }

    /// Total duration of this track.
    public var totalDuration: Double {
        keyframes.reduce(0) { $0 + $1.duration }
    }
}

// MARK: - Keyframe Constructors

/// A keyframe that transitions linearly.
public func LinearKeyframe(_ value: Double, duration: Double, cssProperty: String = "") -> Keyframe {
    Keyframe(cssValue: "\(value)", duration: duration, timingFunction: "linear")
}

/// A keyframe that transitions with spring physics.
public func SpringKeyframe(_ value: Double, duration: Double, spring: SparrowAnimation = .smooth) -> Keyframe {
    Keyframe(cssValue: "\(value)", duration: duration, timingFunction: spring.timingFunction)
}

/// A keyframe with cubic bezier easing.
public func CubicKeyframe(_ value: Double, duration: Double) -> Keyframe {
    Keyframe(cssValue: "\(value)", duration: duration, timingFunction: "ease-in-out")
}

// MARK: - KeyframeTrack Builder

/// Build an array of keyframe tracks from a closure.
@resultBuilder
public struct KeyframeTrackBuilder {
    public static func buildBlock(_ components: AnyKeyframeTrack...) -> [AnyKeyframeTrack] {
        components
    }
}

/// Convenience to create a track with an explicit CSS property name.
public func KeyframeTrack(cssProperty: String, @KeyframeBuilder keyframes: () -> [Keyframe]) -> AnyKeyframeTrack {
    AnyKeyframeTrack(cssProperty: cssProperty, keyframes: keyframes())
}

@resultBuilder
public struct KeyframeBuilder {
    public static func buildBlock(_ components: Keyframe...) -> [Keyframe] {
        components
    }
}
