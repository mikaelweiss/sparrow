/// Font styles matching the design system type scale.
public enum Font: Sendable {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption

    var cssClass: String {
        switch self {
        case .largeTitle: "font-largeTitle"
        case .title: "font-title"
        case .title2: "font-title2"
        case .title3: "font-title3"
        case .headline: "font-headline"
        case .body: "font-body"
        case .callout: "font-callout"
        case .subheadline: "font-subheadline"
        case .footnote: "font-footnote"
        case .caption: "font-caption"
        }
    }

    /// The semantic HTML tag for this font style.
    var htmlTag: String? {
        switch self {
        case .largeTitle: "h1"
        case .title: "h2"
        case .title2: "h3"
        case .title3: "h4"
        case .headline: "h5"
        default: nil
        }
    }
}

public struct FontModifier: ViewModifier, Sendable {
    public let font: Font
    public var cssClasses: [String] { [font.cssClass] }
    public var inlineStyles: [String: String] { [:] }
}

extension View {
    public func font(_ font: Font) -> ModifiedView<Self, FontModifier> {
        modifier(FontModifier(font: font))
    }
}
