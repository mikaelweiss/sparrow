// MARK: - Font Weight

/// Font weight values matching CSS font-weight.
public enum FontWeight: Sendable {
    case ultraLight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black

    var cssValue: Int {
        switch self {
        case .ultraLight: 100
        case .thin: 200
        case .light: 300
        case .regular: 400
        case .medium: 500
        case .semibold: 600
        case .bold: 700
        case .heavy: 800
        case .black: 900
        }
    }

    var cssClass: String {
        "font-weight-\(cssValue)"
    }
}

// MARK: - Font Design

/// Font design families. Changes the font family without affecting size.
public enum FontDesign: Sendable {
    case `default`
    case serif
    case monospaced
    case rounded

    var cssClass: String {
        switch self {
        case .default: "font-design-default"
        case .serif: "font-design-serif"
        case .monospaced: "font-design-monospaced"
        case .rounded: "font-design-rounded"
        }
    }
}

// MARK: - Text Case

/// Text case transformations.
public enum TextCase: Sendable {
    case uppercase
    case lowercase
    case capitalize

    var cssClass: String {
        switch self {
        case .uppercase: "text-uppercase"
        case .lowercase: "text-lowercase"
        case .capitalize: "text-capitalize"
        }
    }
}

// MARK: - Font

/// Font styles for the design system type scale, plus arbitrary sizing.
///
/// The type scale cases (`.title`, `.body`, etc.) map to pre-defined CSS utility
/// classes with size, weight, line-height, and letter-spacing baked in.
///
/// For arbitrary sizing, use `.system(size:weight:design:)` or `.custom(_:size:)`.
/// These render as inline styles since they fall outside the design token system.
///
/// To change just the font family without affecting size, use the `.fontFamily()`
/// or `.fontDesign()` view modifiers instead.
public enum Font: Sendable {
    // Type scale
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

    // System font with arbitrary size
    case system(size: Double, weight: FontWeight = .regular, design: FontDesign = .default)

    // Named custom font with explicit size
    case custom(_ name: String, size: Double)

    var cssClasses: [String] {
        var classes: [String] = []
        if let cls = typeScaleCSSClass { classes.append(cls) }
        if case .system(_, _, let design) = self, design != .default {
            classes.append(design.cssClass)
        }
        return classes
    }

    var inlineStyles: [String: String] {
        switch self {
        case .system(let size, let weight, _):
            return [
                "font-size": remValue(size),
                "font-weight": "\(weight.cssValue)",
            ]
        case .custom(let name, let size):
            return [
                "font-family": "'\(name)', var(--font-body)",
                "font-size": remValue(size),
            ]
        default:
            return [:]
        }
    }

    /// The semantic HTML tag for heading font styles.
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

    private var typeScaleCSSClass: String? {
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
        case .system, .custom: nil
        }
    }
}

/// Convert a pixel value to rem (assuming 16px base).
private func remValue(_ px: Double) -> String {
    let rem = px / 16.0
    if rem == rem.rounded() {
        return "\(Int(rem))rem"
    }
    return "\(rem)rem"
}

// MARK: - Font Modifier

public struct FontModifier: ViewModifier, Sendable {
    public let font: Font
    public var cssClasses: [String] { font.cssClasses }
    public var inlineStyles: [String: String] { font.inlineStyles }
}

// MARK: - Font Weight Modifier

public struct FontWeightModifier: ViewModifier, Sendable {
    public let weight: FontWeight
    public var cssClasses: [String] { [weight.cssClass] }
}

// MARK: - Italic Modifier

public struct ItalicModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["italic"] }
}

// MARK: - Underline Modifier

public struct UnderlineModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["underline"] }
}

// MARK: - Strikethrough Modifier

public struct StrikethroughModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["line-through"] }
}

// MARK: - Tracking Modifier

public struct TrackingModifier: ViewModifier, Sendable {
    public let tracking: Double
    public var inlineStyles: [String: String] {
        ["letter-spacing": "\(tracking)em"]
    }
}

// MARK: - Text Case Modifier

public struct TextCaseModifier: ViewModifier, Sendable {
    public let textCase: TextCase
    public var cssClasses: [String] { [textCase.cssClass] }
}

// MARK: - Font Design Modifier

public struct FontDesignModifier: ViewModifier, Sendable {
    public let design: FontDesign
    public var cssClasses: [String] { [design.cssClass] }
}

// MARK: - Font Family Modifier

/// Changes the font family without affecting size or weight.
/// This is the web-native approach: font-family is independent of font-size.
public struct FontFamilyModifier: ViewModifier, Sendable {
    public let family: String
    public var inlineStyles: [String: String] {
        ["font-family": "'\(family)', var(--font-body)"]
    }
}

// MARK: - View Extensions

extension View {
    public func font(_ font: Font) -> ModifiedView<Self, FontModifier> {
        modifier(FontModifier(font: font))
    }

    public func fontWeight(_ weight: FontWeight) -> ModifiedView<Self, FontWeightModifier> {
        modifier(FontWeightModifier(weight: weight))
    }

    public func bold() -> ModifiedView<Self, FontWeightModifier> {
        fontWeight(.bold)
    }

    public func italic() -> ModifiedView<Self, ItalicModifier> {
        modifier(ItalicModifier())
    }

    public func underline() -> ModifiedView<Self, UnderlineModifier> {
        modifier(UnderlineModifier())
    }

    public func strikethrough() -> ModifiedView<Self, StrikethroughModifier> {
        modifier(StrikethroughModifier())
    }

    public func tracking(_ tracking: Double) -> ModifiedView<Self, TrackingModifier> {
        modifier(TrackingModifier(tracking: tracking))
    }

    public func textCase(_ textCase: TextCase) -> ModifiedView<Self, TextCaseModifier> {
        modifier(TextCaseModifier(textCase: textCase))
    }

    public func fontDesign(_ design: FontDesign) -> ModifiedView<Self, FontDesignModifier> {
        modifier(FontDesignModifier(design: design))
    }

    /// Change font family without affecting size. Unlike SwiftUI, you don't need
    /// to specify a size — font-family and font-size are independent on the web.
    public func fontFamily(_ family: String) -> ModifiedView<Self, FontFamilyModifier> {
        modifier(FontFamilyModifier(family: family))
    }
}
