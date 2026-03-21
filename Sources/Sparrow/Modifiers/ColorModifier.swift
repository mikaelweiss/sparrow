/// Semantic colors from the design system.
public enum SemanticColor: Sendable {
    // MARK: Semantic (role-based)
    case primary
    case secondary
    case accent
    case background
    case surface
    case surfaceSecondary
    case text
    case textSecondary
    case textTertiary
    case error
    case success
    case warning
    case info

    // MARK: Named palette (appearance-based)
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case blue
    case indigo
    case purple
    case pink
    case brown
    case gray
    case white
    case black
    case clear

    // MARK: CSS currentColor
    case current

    // MARK: Escape hatches
    case hex(String)
    case rgb(UInt8, UInt8, UInt8)
    case hsl(Double, Double, Double)

    // MARK: Opacity
    indirect case withOpacity(SemanticColor, Double)

    public func opacity(_ value: Double) -> SemanticColor {
        .withOpacity(self, value)
    }

    /// Create a color from a hex integer literal (e.g. `0xFF0000`).
    public static func hex(_ value: Int) -> SemanticColor {
        .hex(String(format: "#%06X", value & 0xFFFFFF))
    }

    /// Whether this color requires inline styles rather than a pre-defined CSS class.
    var needsInlineStyle: Bool {
        switch self {
        case .hex, .rgb, .hsl, .withOpacity: true
        default: false
        }
    }

    /// CSS class suffix for design-system colors (e.g. "primary", "red", "current").
    /// Only valid when `needsInlineStyle` is false.
    var cssValue: String {
        switch self {
        case .primary: "primary"
        case .secondary: "secondary"
        case .accent: "accent"
        case .background: "background"
        case .surface: "surface"
        case .surfaceSecondary: "surfaceSecondary"
        case .text: "text"
        case .textSecondary: "textSecondary"
        case .textTertiary: "textTertiary"
        case .error: "error"
        case .success: "success"
        case .warning: "warning"
        case .info: "info"
        case .red: "red"
        case .orange: "orange"
        case .yellow: "yellow"
        case .green: "green"
        case .mint: "mint"
        case .teal: "teal"
        case .cyan: "cyan"
        case .blue: "blue"
        case .indigo: "indigo"
        case .purple: "purple"
        case .pink: "pink"
        case .brown: "brown"
        case .gray: "gray"
        case .white: "white"
        case .black: "black"
        case .clear: "clear"
        case .current: "current"
        case .hex, .rgb, .hsl, .withOpacity:
            fatalError("Colors requiring inline styles should not use cssValue")
        }
    }

    /// Resolves to a raw CSS color value for use in inline styles.
    /// `forForeground` selects the correct CSS variable for semantic colors
    /// that map differently depending on context (e.g. `.secondary`).
    func resolvedCSSValue(forForeground: Bool) -> String {
        return switch self {
        // Semantic — foreground and background map to different CSS variables
        case .primary: "var(--primary)"
        case .secondary: forForeground ? "var(--muted-foreground)" : "var(--secondary)"
        case .accent: forForeground ? "var(--accent-foreground)" : "var(--accent)"
        case .background: "var(--background)"
        case .surface: forForeground ? "var(--muted-foreground)" : "var(--muted)"
        case .surfaceSecondary: forForeground ? "var(--accent-foreground)" : "var(--accent)"
        case .text: "var(--foreground)"
        case .textSecondary: "var(--muted-foreground)"
        case .textTertiary: "var(--muted-foreground)"
        case .error: "var(--destructive)"
        case .success: "var(--success)"
        case .warning: "var(--warning)"
        case .info: "var(--info)"

        // Named palette
        case .red: "var(--color-red)"
        case .orange: "var(--color-orange)"
        case .yellow: "var(--color-yellow)"
        case .green: "var(--color-green)"
        case .mint: "var(--color-mint)"
        case .teal: "var(--color-teal)"
        case .cyan: "var(--color-cyan)"
        case .blue: "var(--color-blue)"
        case .indigo: "var(--color-indigo)"
        case .purple: "var(--color-purple)"
        case .pink: "var(--color-pink)"
        case .brown: "var(--color-brown)"
        case .gray: "var(--color-gray)"
        case .white: "var(--color-white)"
        case .black: "var(--color-black)"
        case .clear: "transparent"

        // CSS currentColor
        case .current: "currentColor"

        // Escape hatches
        case .hex(let value): value
        case .rgb(let r, let g, let b): "rgb(\(r), \(g), \(b))"
        case .hsl(let h, let s, let l): "hsl(\(h), \(s)%, \(l)%)"

        // Opacity via color-mix()
        case .withOpacity(let base, let opacity):
            "color-mix(in srgb, \(base.resolvedCSSValue(forForeground: forForeground)) \(Int(opacity * 100))%, transparent)"
        }
    }
}

public struct ForegroundModifier: ViewModifier, Sendable {
    public let color: SemanticColor

    public var cssClasses: [String] {
        color.needsInlineStyle ? [] : ["fg-\(color.cssValue)"]
    }

    public var inlineStyles: [String: String] {
        color.needsInlineStyle ? ["color": color.resolvedCSSValue(forForeground: true)] : [:]
    }
}

public struct BackgroundModifier: ViewModifier, Sendable {
    public let color: SemanticColor
    public var createsLayer: Bool { true }

    public var cssClasses: [String] {
        color.needsInlineStyle ? [] : ["bg-\(color.cssValue)"]
    }

    public var inlineStyles: [String: String] {
        color.needsInlineStyle ? ["background": color.resolvedCSSValue(forForeground: false)] : [:]
    }
}

extension View {
    public func foreground(_ color: SemanticColor) -> ModifiedView<Self, ForegroundModifier> {
        modifier(ForegroundModifier(color: color))
    }

    public func background(_ color: SemanticColor) -> ModifiedView<Self, BackgroundModifier> {
        modifier(BackgroundModifier(color: color))
    }
}
