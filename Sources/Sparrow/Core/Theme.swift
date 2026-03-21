/// Design system theme configuration.
///
/// Customize colors, fonts, and design tokens. Use the builder pattern:
/// ```swift
/// extension Theme {
///     static let app = Theme.default
///         .primary("#6366F1")
///         .fonts(body: "Inter", heading: "Inter", mono: "JetBrains Mono")
///         .dark { dark in
///             dark.background("#0F172A")
///                 .surface("#1E293B")
///         }
/// }
/// ```
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

// MARK: - Builder Methods

extension Theme {
    public func primary(_ color: String) -> Theme {
        with("--primary", color)
    }

    public func secondary(_ color: String) -> Theme {
        with("--secondary", color)
    }

    public func accent(_ color: String) -> Theme {
        with("--accent-foreground", color)
    }

    public func background(_ color: String) -> Theme {
        with("--background", color)
    }

    public func surface(_ color: String) -> Theme {
        with("--card", color)
    }

    public func foreground(_ color: String) -> Theme {
        with("--foreground", color)
    }

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

    /// Configure dark mode overrides. The closure receives a fresh Theme
    /// whose color overrides are applied only in dark mode.
    public func dark(_ configure: (Theme) -> Theme) -> Theme {
        let darkTheme = configure(Theme())
        var copy = self
        copy.darkCSSOverrides.merge(darkTheme.cssOverrides) { _, new in new }
        return copy
    }

    private func with(_ property: String, _ value: String) -> Theme {
        var copy = self
        copy.cssOverrides[property] = value
        return copy
    }
}
