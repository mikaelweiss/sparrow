/// Defines how a view animates when it appears or disappears.
/// Maps to CSS classes that are swapped by the client runtime's presence system.
public struct SparrowTransition: Sendable {
    /// CSS classes for the initial "from" state (applied on render, removed on enter)
    public let enterFromClasses: [String]
    /// CSS classes for the "to" state (added on enter, removed on exit)
    public let enterToClasses: [String]
    /// CSS classes added when the element exits (typically same as enterFrom)
    public let exitToClasses: [String]
    /// CSS transition-property value (e.g., "opacity", "opacity, transform")
    public let transitionProperties: String

    // MARK: - Built-in Transitions

    /// No transition — view appears/disappears instantly.
    public static let identity = SparrowTransition(
        enterFromClasses: [],
        enterToClasses: [],
        exitToClasses: [],
        transitionProperties: ""
    )

    /// Fade in/out.
    public static let opacity = SparrowTransition(
        enterFromClasses: ["sp-opacity-0"],
        enterToClasses: ["sp-opacity-1"],
        exitToClasses: ["sp-opacity-0"],
        transitionProperties: "opacity"
    )

    /// Scale from zero.
    public static let scale = SparrowTransition(
        enterFromClasses: ["sp-scale-0"],
        enterToClasses: ["sp-scale-1"],
        exitToClasses: ["sp-scale-0"],
        transitionProperties: "transform"
    )

    /// Slide in/out from an edge (the view translates from offscreen).
    public static func slide(edge: Edge = .leading) -> SparrowTransition {
        let (fromClass, exitClass) = slideClasses(edge: edge)
        return SparrowTransition(
            enterFromClasses: [fromClass],
            enterToClasses: ["sp-translate-0"],
            exitToClasses: [exitClass],
            transitionProperties: "transform"
        )
    }

    /// Alias for slide — move in from an edge.
    public static func move(edge: Edge) -> SparrowTransition {
        slide(edge: edge)
    }

    /// Slide + fade combined.
    public static func push(edge: Edge) -> SparrowTransition {
        slide(edge: edge).combined(with: .opacity)
    }

    // MARK: - Combining

    /// Combine two transitions so both animate simultaneously.
    public func combined(with other: SparrowTransition) -> SparrowTransition {
        SparrowTransition(
            enterFromClasses: enterFromClasses + other.enterFromClasses,
            enterToClasses: enterToClasses + other.enterToClasses,
            exitToClasses: exitToClasses + other.exitToClasses,
            transitionProperties: [transitionProperties, other.transitionProperties]
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
        )
    }

    /// Different transitions for insertion and removal.
    public static func asymmetric(
        insertion: SparrowTransition,
        removal: SparrowTransition
    ) -> SparrowTransition {
        SparrowTransition(
            enterFromClasses: insertion.enterFromClasses,
            enterToClasses: insertion.enterToClasses,
            exitToClasses: removal.exitToClasses,
            transitionProperties: Set(
                (insertion.transitionProperties + ", " + removal.transitionProperties)
                    .split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            ).joined(separator: ", ")
        )
    }

    // MARK: - Helpers

    private static func slideClasses(edge: Edge) -> (from: String, exit: String) {
        switch edge {
        case .top: return ("sp-translate-y-neg-full", "sp-translate-y-neg-full")
        case .bottom: return ("sp-translate-y-full", "sp-translate-y-full")
        case .leading: return ("sp-translate-x-neg-full", "sp-translate-x-neg-full")
        case .trailing: return ("sp-translate-x-full", "sp-translate-x-full")
        default: return ("sp-translate-x-neg-full", "sp-translate-x-neg-full")
        }
    }
}

// MARK: - ContentTransition

/// Controls how the content of a view animates when it changes.
public enum ContentTransition: Sendable {
    /// Crossfade between old and new content.
    case opacity
    /// Animate numeric text changes with a rolling counter effect.
    case numericText(countsDown: Bool = false)
    /// Interpolate between old and new content (best-effort morph).
    case interpolate
}

// MARK: - SymbolEffect

/// Animation effects for icons and symbols.
public enum SymbolEffect: Sendable {
    case bounce
    case pulse
    case wiggle
    case breathe
    case rotate
}

// MARK: - NavigationTransitionStyle

/// Controls the animation when navigating between pages.
public enum NavigationTransitionStyle: Sendable {
    /// Default crossfade.
    case automatic
    /// Slide from the leading edge.
    case slide
    /// Zoom from a matched geometry source.
    case zoom
}
