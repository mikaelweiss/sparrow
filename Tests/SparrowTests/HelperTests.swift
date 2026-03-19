import Testing
@testable import Sparrow

@Suite("Helper Functions")
struct HelperTests {

    // MARK: - escapeHTML

    @Test("escapeHTML escapes ampersands")
    func escapeAmpersand() {
        #expect(escapeHTML("a & b") == "a &amp; b")
    }

    @Test("escapeHTML escapes angle brackets")
    func escapeAngleBrackets() {
        #expect(escapeHTML("<div>") == "&lt;div&gt;")
    }

    @Test("escapeHTML escapes double quotes")
    func escapeQuotes() {
        #expect(escapeHTML("say \"hello\"") == "say &quot;hello&quot;")
    }

    @Test("escapeHTML handles empty string")
    func escapeEmpty() {
        #expect(escapeHTML("") == "")
    }

    @Test("escapeHTML leaves safe strings unchanged")
    func escapeSafe() {
        #expect(escapeHTML("Hello World 123") == "Hello World 123")
    }

    @Test("escapeHTML handles multiple special characters together")
    func escapeMultiple() {
        #expect(escapeHTML("<a href=\"/\">link & text</a>") == "&lt;a href=&quot;/&quot;&gt;link &amp; text&lt;/a&gt;")
    }

    // MARK: - formatStyles

    @Test("formatStyles formats a single style")
    func formatSingle() {
        let result = formatStyles(["width": "100px"])
        #expect(result == "width: 100px")
    }

    @Test("formatStyles formats empty dictionary")
    func formatEmpty() {
        let result = formatStyles([:])
        #expect(result == "")
    }

    @Test("formatStyles formats multiple styles separated by semicolons")
    func formatMultiple() {
        let result = formatStyles(["width": "100px", "height": "50px"])
        // Order isn't guaranteed, so check both are present
        #expect(result.contains("width: 100px"))
        #expect(result.contains("height: 50px"))
        #expect(result.contains("; "))
    }

    // MARK: - spacingToken

    @Test("spacingToken maps standard values to tokens")
    func spacingStandard() {
        #expect(spacingToken(0) == "0")
        #expect(spacingToken(4) == "1")
        #expect(spacingToken(8) == "2")
        #expect(spacingToken(12) == "3")
        #expect(spacingToken(16) == "4")
        #expect(spacingToken(20) == "5")
        #expect(spacingToken(24) == "6")
        #expect(spacingToken(32) == "8")
        #expect(spacingToken(40) == "10")
        #expect(spacingToken(48) == "12")
        #expect(spacingToken(64) == "16")
    }

    @Test("spacingToken uses bracket syntax for non-standard values")
    func spacingCustom() {
        #expect(spacingToken(7) == "[7]")
        #expect(spacingToken(100) == "[100]")
        #expect(spacingToken(3) == "[3]")
    }

    // MARK: - flattenTuple

    @Test("flattenTuple extracts views from a tuple")
    func flattenBasic() {
        let tuple = (Text("a"), Text("b"), Text("c"))
        let result = flattenTuple(tuple)
        #expect(result.count == 3)
    }

    @Test("flattenTuple handles single non-View value gracefully")
    func flattenSingleNonView() {
        // Mirror of a struct sees its stored properties as children,
        // so flattenTuple on a Text returns 0 (properties aren't Views).
        // This is expected — flattenTuple is only called on actual tuple values.
        let single = Text("solo")
        let result = flattenTuple(single)
        // Text has one stored property (content: String), which isn't a View
        #expect(result.count == 0)
    }

    // MARK: - ModifierContext

    @Test("ModifierContext starts empty")
    func contextEmpty() {
        let ctx = ModifierContext()
        #expect(ctx.cssClasses.isEmpty)
        #expect(ctx.inlineStyles.isEmpty)
        #expect(ctx.htmlTag == nil)
    }

    @Test("ModifierContext accumulates CSS classes from modifiers")
    func contextAccumulates() {
        let ctx = ModifierContext()
            .applying(FontModifier(font: .title))
            .applying(ForegroundModifier(color: .primary))
        #expect(ctx.cssClasses.contains("font-title"))
        #expect(ctx.cssClasses.contains("fg-primary"))
    }

    @Test("ModifierContext sets htmlTag from FontModifier")
    func contextHTMLTag() {
        let ctx = ModifierContext().applying(FontModifier(font: .largeTitle))
        #expect(ctx.htmlTag == "h1")
    }

    @Test("ModifierContext does not set htmlTag for non-heading fonts")
    func contextNoHTMLTag() {
        let ctx = ModifierContext().applying(FontModifier(font: .body))
        #expect(ctx.htmlTag == nil)
    }

    @Test("ModifierContext accumulates inline styles")
    func contextInlineStyles() {
        let ctx = ModifierContext()
            .applying(FrameModifier(width: .fixed(200), height: .fixed(100), maxWidth: nil, minHeight: nil))
        #expect(ctx.inlineStyles["width"] == "200px")
        #expect(ctx.inlineStyles["height"] == "100px")
    }
}
