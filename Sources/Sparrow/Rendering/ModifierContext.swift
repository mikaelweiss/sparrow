/// Accumulated modifier state passed down during rendering.
public struct ModifierContext {
    public var cssClasses: [String] = []
    public var inlineStyles: [String: String] = [:]
    /// HTML attributes (aria-label, disabled, title, etc.).
    public var htmlAttributes: [String: String] = [:]
    /// The HTML tag override from a font modifier (e.g., "h1" for .largeTitle).
    public var htmlTag: String? = nil
    /// Custom HTML id from `.id("section")` modifier, for anchor/fragment links.
    public var customId: String? = nil

    public init() {}

    /// HTML attributes as ordered tuples for VNode extraAttrs.
    var htmlAttributePairs: [(key: String, value: String)] {
        htmlAttributes.sorted(by: { $0.key < $1.key }).map { (key: $0.key, value: $0.value) }
    }

    /// Create a new context with an additional modifier applied.
    public func applying(_ modifier: any ViewModifier) -> ModifierContext {
        var copy = self
        copy.cssClasses.append(contentsOf: modifier.cssClasses)
        for (key, value) in modifier.inlineStyles {
            copy.inlineStyles[key] = value
        }
        for (key, value) in modifier.htmlAttributes {
            copy.htmlAttributes[key] = value
        }
        // Check if this is a font modifier and extract the HTML tag
        if let fontMod = modifier as? FontModifier, let tag = fontMod.font.htmlTag {
            copy.htmlTag = tag
        }
        // Check if this is an ID modifier and extract the custom ID
        if let idMod = modifier as? IDModifier {
            copy.customId = idMod.identifier
        }
        return copy
    }
}
