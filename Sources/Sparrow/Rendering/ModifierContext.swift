/// Accumulated modifier state passed down during rendering.
public struct ModifierContext {
    public var cssClasses: [String] = []
    public var inlineStyles: [String: String] = [:]
    /// The HTML tag override from a font modifier (e.g., "h1" for .largeTitle).
    public var htmlTag: String? = nil
    /// Custom HTML id from `.id("section")` modifier, for anchor/fragment links.
    public var customId: String? = nil
    /// HTML data attributes from modifiers (e.g., animation/transition hooks).
    public var dataAttributes: [String: String] = [:]

    public init() {}

    /// Create a new context with an additional modifier applied.
    public func applying(_ modifier: any ViewModifier) -> ModifierContext {
        var copy = self
        copy.cssClasses.append(contentsOf: modifier.cssClasses)
        for (key, value) in modifier.inlineStyles {
            copy.inlineStyles[key] = value
        }
        for (key, value) in modifier.dataAttributes {
            copy.dataAttributes[key] = value
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
