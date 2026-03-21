/// Applies a repeating animation effect to a view (typically icons).
/// Maps to CSS keyframe animations.
public struct SymbolEffectModifier: ViewModifier, Sendable {
    public let effect: SymbolEffect

    public var cssClasses: [String] {
        switch effect {
        case .bounce: return ["sp-animate-bounce"]
        case .pulse: return ["sp-animate-pulse"]
        case .wiggle: return ["sp-animate-wiggle"]
        case .breathe: return ["sp-animate-breathe"]
        case .rotate: return ["sp-animate-spin"]
        }
    }
}

extension View {
    /// Apply a repeating animation effect to this view.
    public func symbolEffect(_ effect: SymbolEffect) -> ModifiedView<Self, SymbolEffectModifier> {
        modifier(SymbolEffectModifier(effect: effect))
    }
}
