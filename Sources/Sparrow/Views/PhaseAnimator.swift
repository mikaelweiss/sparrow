/// Cycles through a sequence of phases, rendering the content view at each phase
/// and generating CSS @keyframes to animate between them automatically.
///
/// Usage:
/// ```swift
/// PhaseAnimator([false, true]) { phase in
///     Circle()
///         .opacity(phase ? 1.0 : 0.3)
///         .scaleEffect(phase ? 1.0 : 0.8)
/// } animation: { _ in .easeInOut }
/// ```
///
/// The renderer evaluates the content at each phase, extracts the CSS differences,
/// and generates an inline @keyframes rule that loops continuously.
public struct PhaseAnimator<Phase: Hashable & Sendable>: View, _PhaseAnimatorRenderable {
    public typealias Body = Never

    let phases: [Phase]
    let content: @Sendable (Phase) -> any View
    let animation: @Sendable (Phase) -> SparrowAnimation

    public init(
        _ phases: [Phase],
        @ViewBuilder content: @escaping @Sendable (Phase) -> any View,
        animation: @escaping @Sendable (Phase) -> SparrowAnimation = { _ in .default }
    ) {
        self.phases = phases
        self.content = content
        self.animation = animation
    }

    public var body: Never { fatalError("PhaseAnimator renders directly") }

    // MARK: - _PhaseAnimatorRenderable

    var _phaseCount: Int { phases.count }

    func _contentForPhase(_ index: Int) -> any View {
        content(phases[index])
    }

    func _animationForPhase(_ index: Int) -> SparrowAnimation {
        animation(phases[index])
    }
}

/// Internal protocol so the renderer can dispatch to PhaseAnimator regardless of generic parameter.
protocol _PhaseAnimatorRenderable {
    var _phaseCount: Int { get }
    func _contentForPhase(_ index: Int) -> any View
    func _animationForPhase(_ index: Int) -> SparrowAnimation
}
