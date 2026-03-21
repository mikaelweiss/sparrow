/// Design system theme configuration.
///
/// Customize colors, fonts, and design tokens. The builder pattern sets
/// color pairs automatically — when you set a background color, the
/// contrasting foreground is derived for you:
///
/// ```swift
/// extension Theme {
///     static let app = Theme.default
///         .neutral(.slate)
///         .primary("#6366F1")
///         .fonts(body: "Inter", heading: "Inter", mono: "JetBrains Mono")
///         .dark { dark in
///             dark.background("#0F172A")
///                 .surface("#1E293B")
///         }
/// }
/// ```
///
/// Use `.neutral(_:)` to pick a gray family (zinc, slate, stone, neutral, gray).
/// This sets all neutral surfaces at once. Then use `.primary(_:)` to set your
/// accent color. Change two things, everything reacts.
///
/// Font files go in `Assets/fonts/`. Register them via `FontConfig.sources`:
/// ```swift
/// Theme.default.fonts(FontConfig(
///     body: "Inter",
///     heading: "Inter",
///     sources: [
///         FontRegistration(
///             family: "Inter",
///             source: .local(path: "fonts/Inter-Variable.woff2"),
///             weightRange: 100...900
///         )
///     ]
/// ))
/// ```
public struct Theme: Sendable {
    public var fonts: FontConfig
    var cssOverrides: [String: String]
    var darkCSSOverrides: [String: String]

    public static let `default` = Theme()

    public init(fonts: FontConfig = .default) {
        self.fonts = fonts
        self.cssOverrides = [:]
        self.darkCSSOverrides = [:]
    }
}

// MARK: - Gray Palettes

/// Pre-built gray palettes matching shadcn/ui's neutral color families.
/// Each palette controls all neutral surfaces: background, card, muted,
/// secondary, accent, border, and input — in both light and dark modes.
public enum GrayPalette: String, Sendable, CaseIterable {
    /// Cool zinc gray (default). Neutral with a slight blue-purple tint.
    case zinc
    /// Blue-tinted gray. Cooler and more "digital" feeling.
    case slate
    /// Warm gray with earthy undertones.
    case stone
    /// Pure gray with zero color tint.
    case neutral
    /// Slightly cool gray with a blue lean, between zinc and slate.
    case gray

    /// Light mode CSS variable overrides for this palette.
    var lightVariables: [String: String] {
        switch self {
        case .zinc:
            return [
                "--background": "hsl(0 0% 100%)",
                "--foreground": "hsl(240 10% 3.9%)",
                "--card": "hsl(0 0% 100%)",
                "--card-foreground": "hsl(240 10% 3.9%)",
                "--popover": "hsl(0 0% 100%)",
                "--popover-foreground": "hsl(240 10% 3.9%)",
                "--muted": "hsl(240 4.8% 95.9%)",
                "--muted-foreground": "hsl(240 3.8% 46.1%)",
                "--secondary": "hsl(240 4.8% 95.9%)",
                "--secondary-foreground": "hsl(240 5.9% 10%)",
                "--accent": "hsl(240 4.8% 95.9%)",
                "--accent-foreground": "hsl(240 5.9% 10%)",
                "--border": "hsl(240 5.9% 90%)",
                "--input": "hsl(240 5.9% 90%)",
            ]
        case .slate:
            return [
                "--background": "hsl(0 0% 100%)",
                "--foreground": "hsl(222.2 84% 4.9%)",
                "--card": "hsl(0 0% 100%)",
                "--card-foreground": "hsl(222.2 84% 4.9%)",
                "--popover": "hsl(0 0% 100%)",
                "--popover-foreground": "hsl(222.2 84% 4.9%)",
                "--muted": "hsl(210 40% 96.1%)",
                "--muted-foreground": "hsl(215.4 16.3% 46.9%)",
                "--secondary": "hsl(210 40% 96.1%)",
                "--secondary-foreground": "hsl(222.2 47.4% 11.2%)",
                "--accent": "hsl(210 40% 96.1%)",
                "--accent-foreground": "hsl(222.2 47.4% 11.2%)",
                "--border": "hsl(214.3 31.8% 91.4%)",
                "--input": "hsl(214.3 31.8% 91.4%)",
            ]
        case .stone:
            return [
                "--background": "hsl(0 0% 100%)",
                "--foreground": "hsl(20 14.3% 4.1%)",
                "--card": "hsl(0 0% 100%)",
                "--card-foreground": "hsl(20 14.3% 4.1%)",
                "--popover": "hsl(0 0% 100%)",
                "--popover-foreground": "hsl(20 14.3% 4.1%)",
                "--muted": "hsl(60 4.8% 95.9%)",
                "--muted-foreground": "hsl(25 5.3% 44.7%)",
                "--secondary": "hsl(60 4.8% 95.9%)",
                "--secondary-foreground": "hsl(24 9.8% 10%)",
                "--accent": "hsl(60 4.8% 95.9%)",
                "--accent-foreground": "hsl(24 9.8% 10%)",
                "--border": "hsl(20 5.9% 90%)",
                "--input": "hsl(20 5.9% 90%)",
            ]
        case .neutral:
            return [
                "--background": "hsl(0 0% 100%)",
                "--foreground": "hsl(0 0% 3.9%)",
                "--card": "hsl(0 0% 100%)",
                "--card-foreground": "hsl(0 0% 3.9%)",
                "--popover": "hsl(0 0% 100%)",
                "--popover-foreground": "hsl(0 0% 3.9%)",
                "--muted": "hsl(0 0% 96.1%)",
                "--muted-foreground": "hsl(0 0% 45.1%)",
                "--secondary": "hsl(0 0% 96.1%)",
                "--secondary-foreground": "hsl(0 0% 9%)",
                "--accent": "hsl(0 0% 96.1%)",
                "--accent-foreground": "hsl(0 0% 9%)",
                "--border": "hsl(0 0% 89.8%)",
                "--input": "hsl(0 0% 89.8%)",
            ]
        case .gray:
            return [
                "--background": "hsl(0 0% 100%)",
                "--foreground": "hsl(224 71.4% 4.1%)",
                "--card": "hsl(0 0% 100%)",
                "--card-foreground": "hsl(224 71.4% 4.1%)",
                "--popover": "hsl(0 0% 100%)",
                "--popover-foreground": "hsl(224 71.4% 4.1%)",
                "--muted": "hsl(220 14.3% 95.9%)",
                "--muted-foreground": "hsl(220 8.9% 46.1%)",
                "--secondary": "hsl(220 14.3% 95.9%)",
                "--secondary-foreground": "hsl(220.9 39.3% 11%)",
                "--accent": "hsl(220 14.3% 95.9%)",
                "--accent-foreground": "hsl(220.9 39.3% 11%)",
                "--border": "hsl(220 13% 91%)",
                "--input": "hsl(220 13% 91%)",
            ]
        }
    }

    /// Dark mode CSS variable overrides for this palette.
    var darkVariables: [String: String] {
        switch self {
        case .zinc:
            return [
                "--background": "hsl(240 10% 3.9%)",
                "--foreground": "hsl(0 0% 98%)",
                "--card": "hsl(240 10% 3.9%)",
                "--card-foreground": "hsl(0 0% 98%)",
                "--popover": "hsl(240 10% 3.9%)",
                "--popover-foreground": "hsl(0 0% 98%)",
                "--muted": "hsl(240 3.7% 15.9%)",
                "--muted-foreground": "hsl(240 5% 64.9%)",
                "--secondary": "hsl(240 3.7% 15.9%)",
                "--secondary-foreground": "hsl(0 0% 98%)",
                "--accent": "hsl(240 3.7% 15.9%)",
                "--accent-foreground": "hsl(0 0% 98%)",
                "--border": "hsl(240 3.7% 15.9%)",
                "--input": "hsl(240 3.7% 15.9%)",
            ]
        case .slate:
            return [
                "--background": "hsl(222.2 84% 4.9%)",
                "--foreground": "hsl(210 40% 98%)",
                "--card": "hsl(222.2 84% 4.9%)",
                "--card-foreground": "hsl(210 40% 98%)",
                "--popover": "hsl(222.2 84% 4.9%)",
                "--popover-foreground": "hsl(210 40% 98%)",
                "--muted": "hsl(217.2 32.6% 17.5%)",
                "--muted-foreground": "hsl(215 20.2% 65.1%)",
                "--secondary": "hsl(217.2 32.6% 17.5%)",
                "--secondary-foreground": "hsl(210 40% 98%)",
                "--accent": "hsl(217.2 32.6% 17.5%)",
                "--accent-foreground": "hsl(210 40% 98%)",
                "--border": "hsl(217.2 32.6% 17.5%)",
                "--input": "hsl(217.2 32.6% 17.5%)",
            ]
        case .stone:
            return [
                "--background": "hsl(20 14.3% 4.1%)",
                "--foreground": "hsl(60 9.1% 97.8%)",
                "--card": "hsl(20 14.3% 4.1%)",
                "--card-foreground": "hsl(60 9.1% 97.8%)",
                "--popover": "hsl(20 14.3% 4.1%)",
                "--popover-foreground": "hsl(60 9.1% 97.8%)",
                "--muted": "hsl(12 6.5% 15.1%)",
                "--muted-foreground": "hsl(24 5.4% 63.9%)",
                "--secondary": "hsl(12 6.5% 15.1%)",
                "--secondary-foreground": "hsl(60 9.1% 97.8%)",
                "--accent": "hsl(12 6.5% 15.1%)",
                "--accent-foreground": "hsl(60 9.1% 97.8%)",
                "--border": "hsl(12 6.5% 15.1%)",
                "--input": "hsl(12 6.5% 15.1%)",
            ]
        case .neutral:
            return [
                "--background": "hsl(0 0% 3.9%)",
                "--foreground": "hsl(0 0% 98%)",
                "--card": "hsl(0 0% 3.9%)",
                "--card-foreground": "hsl(0 0% 98%)",
                "--popover": "hsl(0 0% 3.9%)",
                "--popover-foreground": "hsl(0 0% 98%)",
                "--muted": "hsl(0 0% 14.9%)",
                "--muted-foreground": "hsl(0 0% 63.9%)",
                "--secondary": "hsl(0 0% 14.9%)",
                "--secondary-foreground": "hsl(0 0% 98%)",
                "--accent": "hsl(0 0% 14.9%)",
                "--accent-foreground": "hsl(0 0% 98%)",
                "--border": "hsl(0 0% 14.9%)",
                "--input": "hsl(0 0% 14.9%)",
            ]
        case .gray:
            return [
                "--background": "hsl(224 71.4% 4.1%)",
                "--foreground": "hsl(210 20% 98%)",
                "--card": "hsl(224 71.4% 4.1%)",
                "--card-foreground": "hsl(210 20% 98%)",
                "--popover": "hsl(224 71.4% 4.1%)",
                "--popover-foreground": "hsl(210 20% 98%)",
                "--muted": "hsl(215 27.9% 16.9%)",
                "--muted-foreground": "hsl(217.9 10.6% 64.9%)",
                "--secondary": "hsl(215 27.9% 16.9%)",
                "--secondary-foreground": "hsl(210 20% 98%)",
                "--accent": "hsl(215 27.9% 16.9%)",
                "--accent-foreground": "hsl(210 20% 98%)",
                "--border": "hsl(215 27.9% 16.9%)",
                "--input": "hsl(215 27.9% 16.9%)",
            ]
        }
    }
}

// MARK: - Builder Methods

extension Theme {

    // MARK: Color pairs (auto-derive foreground)

    /// Set primary color (buttons, links, active states, focus rings).
    /// Automatically derives `--primary-foreground` for contrast and updates `--ring`.
    public func primary(_ color: String) -> Theme {
        let hsl = ColorUtilities.ensureHSL(color)
        let fg = ColorUtilities.autoForeground(for: color)
        return with("--primary", hsl)
            .with("--primary-foreground", fg)
            .with("--ring", hsl)
    }

    /// Set secondary color (secondary buttons, less prominent actions).
    /// Automatically derives `--secondary-foreground`.
    public func secondary(_ color: String) -> Theme {
        let hsl = ColorUtilities.ensureHSL(color)
        let fg = ColorUtilities.autoForeground(for: color)
        return with("--secondary", hsl)
            .with("--secondary-foreground", fg)
    }

    /// Set accent color (hover states, highlighted items).
    /// Automatically derives `--accent-foreground`.
    public func accent(_ color: String) -> Theme {
        let hsl = ColorUtilities.ensureHSL(color)
        let fg = ColorUtilities.autoForeground(for: color)
        return with("--accent", hsl)
            .with("--accent-foreground", fg)
    }

    /// Set page background color.
    /// Automatically derives `--foreground` for text contrast.
    public func background(_ color: String) -> Theme {
        let hsl = ColorUtilities.ensureHSL(color)
        let fg = ColorUtilities.autoForeground(for: color)
        return with("--background", hsl)
            .with("--foreground", fg)
    }

    /// Set surface / card color (elevated panels, cards).
    /// Automatically derives `--card-foreground`.
    public func surface(_ color: String) -> Theme {
        let hsl = ColorUtilities.ensureHSL(color)
        let fg = ColorUtilities.autoForeground(for: color)
        return with("--card", hsl)
            .with("--card-foreground", fg)
            .with("--popover", hsl)
            .with("--popover-foreground", fg)
    }

    /// Set muted color (subtle backgrounds, disabled states).
    /// Automatically derives `--muted-foreground`.
    public func muted(_ color: String) -> Theme {
        let hsl = ColorUtilities.ensureHSL(color)
        let fg = ColorUtilities.autoForeground(for: color)
        return with("--muted", hsl)
            .with("--muted-foreground", fg)
    }

    /// Set destructive color (delete buttons, error states).
    /// Automatically derives `--destructive-foreground`.
    public func destructive(_ color: String) -> Theme {
        let hsl = ColorUtilities.ensureHSL(color)
        let fg = ColorUtilities.autoForeground(for: color)
        return with("--destructive", hsl)
            .with("--destructive-foreground", fg)
    }

    /// Set foreground (text) color directly, without auto-deriving.
    public func foreground(_ color: String) -> Theme {
        with("--foreground", ColorUtilities.ensureHSL(color))
    }

    // MARK: Utility tokens

    /// Set border color (all borders and input borders).
    public func border(_ color: String) -> Theme {
        let hsl = ColorUtilities.ensureHSL(color)
        return with("--border", hsl)
            .with("--input", hsl)
    }

    /// Set focus ring color.
    public func ring(_ color: String) -> Theme {
        with("--ring", ColorUtilities.ensureHSL(color))
    }

    /// Set border radius base value.
    public func radius(_ value: String) -> Theme {
        with("--radius", value)
    }

    // MARK: Gray palette

    /// Apply a pre-built gray palette. Controls all neutral surfaces (background,
    /// card, muted, secondary, accent, border, input) in both light and dark modes.
    ///
    /// Combine with `.primary(_:)` for full theming in two calls:
    /// ```swift
    /// Theme.default.neutral(.slate).primary("#6366F1")
    /// ```
    public func neutral(_ palette: GrayPalette) -> Theme {
        var theme = self
        for (key, value) in palette.lightVariables {
            theme = theme.with(key, value)
        }
        for (key, value) in palette.darkVariables {
            theme.darkCSSOverrides[key] = value
        }
        return theme
    }

    // MARK: Fonts

    /// Set all three font families at once. Font sources must be registered
    /// separately via `.fonts(FontConfig(...))` if using custom font files.
    public func fonts(body: String, heading: String? = nil, mono: String? = nil) -> Theme {
        var copy = self
        copy.fonts = FontConfig(
            body: body,
            heading: heading ?? body,
            mono: mono ?? self.fonts.mono,
            sources: self.fonts.sources
        )
        return copy
    }

    /// Set the full font configuration including sources.
    public func fonts(_ config: FontConfig) -> Theme {
        var copy = self
        copy.fonts = config
        return copy
    }

    // MARK: Dark mode

    /// Configure dark mode overrides. The closure receives a fresh Theme
    /// whose color overrides are applied only in dark mode.
    public func dark(_ configure: (Theme) -> Theme) -> Theme {
        let darkTheme = configure(Theme())
        var copy = self
        copy.darkCSSOverrides.merge(darkTheme.cssOverrides) { _, new in new }
        return copy
    }

    // MARK: Raw override

    /// Set an arbitrary CSS variable override. Prefer the named methods above.
    public func variable(_ name: String, _ value: String) -> Theme {
        with(name, value)
    }

    // MARK: Internal

    private func with(_ property: String, _ value: String) -> Theme {
        var copy = self
        copy.cssOverrides[property] = value
        return copy
    }
}
