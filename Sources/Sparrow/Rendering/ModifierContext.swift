/// Accumulated modifier state passed down during rendering.
public struct ModifierContext {
    public var cssClasses: [String] = []
    public var inlineStyles: [String: String] = [:]
    /// The HTML tag override from a font modifier (e.g., "h1" for .largeTitle).
    public var htmlTag: String? = nil

    public init() {}

    /// Create a new context with an additional modifier applied.
    public func applying(_ modifier: any ViewModifier) -> ModifierContext {
        var copy = self
        copy.cssClasses.append(contentsOf: modifier.cssClasses)
        for (key, value) in modifier.inlineStyles {
            copy.inlineStyles[key] = value
        }
        // Check if this is a font modifier and extract the HTML tag
        if let fontMod = modifier as? FontModifier, let tag = fontMod.font.htmlTag {
            copy.htmlTag = tag
        }
        return copy
    }
}
