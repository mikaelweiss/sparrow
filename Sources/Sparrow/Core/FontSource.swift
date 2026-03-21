/// Where a font's files come from.
public enum FontSource: Sendable {
    /// The platform's default system font stack. No download needed.
    case system

    /// A self-hosted font file (WOFF2 recommended).
    /// Path is relative to the project's assets directory.
    case local(path: String)

    /// A Google Fonts family. Sparrow fetches at build time and self-hosts
    /// the files to avoid runtime third-party requests.
    case google(family: String)

    /// A remote URL pointing to a font file (WOFF2 recommended).
    case url(String)
}

/// A single font registration that maps a family name to a source.
public struct FontRegistration: Sendable {
    public let family: String
    public let source: FontSource
    /// For variable fonts: the weight axis range (e.g., 100...900).
    /// Nil for static fonts.
    public let weightRange: ClosedRange<Int>?
    /// "normal" or "italic". Nil means both.
    public let style: String?

    public init(
        family: String,
        source: FontSource,
        weightRange: ClosedRange<Int>? = nil,
        style: String? = nil
    ) {
        self.family = family
        self.source = source
        self.weightRange = weightRange
        self.style = style
    }
}

/// Font configuration for the design system theme.
///
/// Defines which font families are used for body text, headings, and monospaced
/// content, plus any custom font registrations that generate `@font-face` rules.
///
/// ```swift
/// FontConfig(
///     body: "Inter",
///     heading: "Inter",
///     mono: "JetBrains Mono",
///     sources: [
///         // Variable font — one file covers all weights
///         FontRegistration(
///             family: "Inter",
///             source: .local(path: "fonts/Inter-Variable.woff2"),
///             weightRange: 100...900
///         ),
///         // Google Font — fetched at build time
///         FontRegistration(
///             family: "JetBrains Mono",
///             source: .google(family: "JetBrains Mono")
///         ),
///     ]
/// )
/// ```
public struct FontConfig: Sendable {
    /// Font family for body text, callout, subheadline, footnote, caption.
    public var body: String
    /// Font family for headings (largeTitle, title, title2, title3, headline).
    public var heading: String
    /// Font family for monospaced content (code blocks, pre).
    public var mono: String
    /// Custom font registrations that generate `@font-face` rules in the CSS output.
    public var sources: [FontRegistration]

    public init(
        body: String = "system-ui",
        heading: String = "system-ui",
        mono: String = "ui-monospace",
        sources: [FontRegistration] = []
    ) {
        self.body = body
        self.heading = heading
        self.mono = mono
        self.sources = sources
    }

    /// The default font config uses the system font stack.
    public static let `default` = FontConfig()
}
