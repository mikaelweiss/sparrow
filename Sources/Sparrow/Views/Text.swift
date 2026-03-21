/// A span of text with optional inline styling.
/// Used internally by `Text` for concatenation with the `+` operator.
public struct TextSpan: Sendable {
    public let content: String
    public var fontWeight: FontWeight? = nil
    public var isItalic: Bool = false
    public var isUnderline: Bool = false
    public var isStrikethrough: Bool = false

    public var hasInlineStyles: Bool {
        fontWeight != nil || isItalic || isUnderline || isStrikethrough
    }
}

/// Displays a string of text. Renders to `<p>`, `<span>`, or `<h1>`-`<h6>` depending
/// on the font modifier applied.
///
/// Text supports inline styling via Text-level modifiers and concatenation:
/// ```swift
/// Text("Hello ").bold() + Text("world").italic()
/// // Renders: <p><strong>Hello </strong><em>world</em></p>
/// ```
///
/// For element-level styling (CSS classes on the outer tag), use View modifiers:
/// ```swift
/// Text("Hello")
///     .font(.title)
///     .foreground(.primary)
/// ```
public struct Text: PrimitiveView, Sendable {
    public let spans: [TextSpan]

    /// The plain text content of all spans combined.
    public var content: String {
        spans.map(\.content).joined()
    }

    public init(_ content: String) {
        self.spans = [TextSpan(content: content)]
    }

    init(spans: [TextSpan]) {
        self.spans = spans
    }
}

// MARK: - Text-Level Modifiers
//
// These return Text (not ModifiedView) so they can be used with the + operator.
// Swift prefers these over the View-extension versions when called on Text.

extension Text {
    public func bold() -> Text {
        Text(spans: spans.map { var s = $0; s.fontWeight = .bold; return s })
    }

    public func italic() -> Text {
        Text(spans: spans.map { var s = $0; s.isItalic = true; return s })
    }

    public func underline() -> Text {
        Text(spans: spans.map { var s = $0; s.isUnderline = true; return s })
    }

    public func strikethrough() -> Text {
        Text(spans: spans.map { var s = $0; s.isStrikethrough = true; return s })
    }

    public func fontWeight(_ weight: FontWeight) -> Text {
        Text(spans: spans.map { var s = $0; s.fontWeight = weight; return s })
    }

    public static func + (lhs: Text, rhs: Text) -> Text {
        Text(spans: lhs.spans + rhs.spans)
    }
}
