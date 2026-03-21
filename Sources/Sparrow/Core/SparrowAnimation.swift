import Foundation

/// An animation curve that controls how property changes transition over time.
/// Maps to CSS transitions (for property changes) and CSS animation timing (for keyframes).
public struct SparrowAnimation: Sendable, Equatable {
    public let duration: Double
    public let timingFunction: String
    public let delay: Double
    public let repeatBehavior: RepeatBehavior

    public enum RepeatBehavior: Sendable, Equatable {
        case none
        case count(Int, autoreverses: Bool)
        case forever(autoreverses: Bool)
    }

    public init(duration: Double = 0.35, timingFunction: String = "ease", delay: Double = 0) {
        self.duration = duration
        self.timingFunction = timingFunction
        self.delay = delay
        self.repeatBehavior = .none
    }

    init(duration: Double, timingFunction: String, delay: Double, repeatBehavior: RepeatBehavior) {
        self.duration = duration
        self.timingFunction = timingFunction
        self.delay = delay
        self.repeatBehavior = repeatBehavior
    }

    // MARK: - Standard Curves

    public static let `default` = SparrowAnimation(duration: 0.35, timingFunction: "cubic-bezier(0.2, 0, 0, 1)")
    public static let linear = SparrowAnimation(duration: 0.35, timingFunction: "linear")
    public static let easeIn = SparrowAnimation(duration: 0.35, timingFunction: "cubic-bezier(0.42, 0, 1, 1)")
    public static let easeOut = SparrowAnimation(duration: 0.35, timingFunction: "cubic-bezier(0, 0, 0.58, 1)")
    public static let easeInOut = SparrowAnimation(duration: 0.35, timingFunction: "cubic-bezier(0.42, 0, 0.58, 1)")

    // MARK: - Springs

    /// A spring animation with configurable duration and bounce.
    /// - Parameters:
    ///   - duration: Perceptual duration in seconds (how long the animation feels).
    ///   - bounce: Bounce amount. 0 = no overshoot (critically damped), 0.3 = moderate bounce, 0.5 = very bouncy.
    public static func spring(duration: Double = 0.5, bounce: Double = 0.0) -> SparrowAnimation {
        let linearPoints = simulateSpring(duration: duration, bounce: bounce)
        let totalDuration = springSettlingTime(duration: duration, bounce: bounce)
        return SparrowAnimation(duration: totalDuration, timingFunction: "linear(\(linearPoints))")
    }

    public static let bouncy = spring(duration: 0.5, bounce: 0.3)
    public static let snappy = spring(duration: 0.3, bounce: 0.15)
    public static let smooth = spring(duration: 0.5, bounce: 0.0)

    // MARK: - Modifiers

    public func speed(_ multiplier: Double) -> SparrowAnimation {
        SparrowAnimation(
            duration: duration / max(multiplier, 0.01),
            timingFunction: timingFunction,
            delay: delay,
            repeatBehavior: repeatBehavior
        )
    }

    public func delay(_ seconds: Double) -> SparrowAnimation {
        SparrowAnimation(
            duration: duration,
            timingFunction: timingFunction,
            delay: seconds,
            repeatBehavior: repeatBehavior
        )
    }

    public func repeatCount(_ count: Int, autoreverses: Bool = true) -> SparrowAnimation {
        SparrowAnimation(
            duration: duration,
            timingFunction: timingFunction,
            delay: delay,
            repeatBehavior: .count(count, autoreverses: autoreverses)
        )
    }

    public func repeatForever(autoreverses: Bool = true) -> SparrowAnimation {
        SparrowAnimation(
            duration: duration,
            timingFunction: timingFunction,
            delay: delay,
            repeatBehavior: .forever(autoreverses: autoreverses)
        )
    }

    // MARK: - CSS Output

    /// CSS transition shorthand (e.g., "all 350ms cubic-bezier(0.2, 0, 0, 1)")
    public var cssTransition: String {
        var parts = "all \(formatDuration(duration)) \(timingFunction)"
        if delay > 0 {
            parts += " \(formatDuration(delay))"
        }
        return parts
    }

    /// CSS transition for specific properties (e.g., "opacity, transform 350ms ease")
    public func cssTransition(properties: String) -> String {
        var parts = "\(properties) \(formatDuration(duration)) \(timingFunction)"
        if delay > 0 {
            parts += " \(formatDuration(delay))"
        }
        return parts
    }

    /// CSS animation shorthand timing portion (e.g., "350ms ease infinite alternate")
    public var cssAnimationTiming: String {
        var parts = "\(formatDuration(duration)) \(timingFunction)"
        if delay > 0 {
            parts += " \(formatDuration(delay))"
        }
        switch repeatBehavior {
        case .none: break
        case .count(let n, let autoreverses):
            parts += " \(n)"
            if autoreverses { parts += " alternate" }
        case .forever(let autoreverses):
            parts += " infinite"
            if autoreverses { parts += " alternate" }
        }
        return parts
    }

    func formatDuration(_ seconds: Double) -> String {
        if seconds < 1 {
            return "\(Int(seconds * 1000))ms"
        }
        return String(format: "%.2fs", seconds)
    }

    // MARK: - Spring Simulation

    private static func simulateSpring(duration: Double, bounce: Double, sampleCount: Int = 32) -> String {
        let samples = springCurve(duration: duration, bounce: bounce, sampleCount: sampleCount)
        return samples.map { String(format: "%.4f", $0) }.joined(separator: ", ")
    }

    static func springCurve(duration: Double, bounce: Double, sampleCount: Int = 32) -> [Double] {
        let dampingRatio = max(0.001, 1.0 - bounce)
        let angularFreq = 2.0 * Double.pi / duration
        let settlingTime = springSettlingTime(duration: duration, bounce: bounce)

        var samples: [Double] = []
        for i in 0..<sampleCount {
            let t = settlingTime * Double(i) / Double(sampleCount - 1)
            samples.append(springValue(t: t, dampingRatio: dampingRatio, angularFreq: angularFreq))
        }

        samples[0] = 0
        samples[sampleCount - 1] = 1
        return samples
    }

    static func springSettlingTime(duration: Double, bounce: Double) -> Double {
        let dampingRatio = max(0.001, 1.0 - bounce)
        let angularFreq = 2.0 * Double.pi / duration
        // Time for envelope e^(-ζωt) to decay below 0.001
        let settlingTime = -log(0.001) / (dampingRatio * angularFreq)
        return min(settlingTime, duration * 3)
    }

    private static func springValue(t: Double, dampingRatio: Double, angularFreq: Double) -> Double {
        let zeta = dampingRatio
        let omega = angularFreq

        if zeta < 1 {
            // Underdamped — oscillates and settles
            let omegaD = omega * sqrt(1 - zeta * zeta)
            let envelope = exp(-zeta * omega * t)
            return 1 - envelope * (cos(omegaD * t) + (zeta / sqrt(1 - zeta * zeta)) * sin(omegaD * t))
        } else if zeta > 1 {
            // Overdamped — slow exponential approach
            let s1 = -omega * (zeta + sqrt(zeta * zeta - 1))
            let s2 = -omega * (zeta - sqrt(zeta * zeta - 1))
            let c2 = -s1 / (s2 - s1)
            let c1 = 1 - c2
            return 1 - c1 * exp(s1 * t) - c2 * exp(s2 * t)
        } else {
            // Critically damped — fastest approach without overshoot
            return 1 - (1 + omega * t) * exp(-omega * t)
        }
    }
}

// MARK: - withAnimation

/// Wraps a state mutation so all resulting view changes animate.
/// Sets a pending animation on the current session's state storage,
/// which the renderer reads during the next render cycle.
public func withAnimation(_ animation: SparrowAnimation = .default, _ body: () -> Void) {
    StateStorage.current?.pendingAnimation = animation
    body()
}
