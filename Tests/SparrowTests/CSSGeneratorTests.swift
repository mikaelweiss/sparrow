import Testing
@testable import Sparrow

@Suite("CSSGenerator")
struct CSSGeneratorTests {

    @Test("Default stylesheet is non-empty")
    func stylesheetExists() {
        #expect(!CSSGenerator.defaultStylesheet.isEmpty)
    }

    @Test("Stylesheet includes CSS reset")
    func cssReset() {
        #expect(CSSGenerator.defaultStylesheet.contains("box-sizing: border-box"))
    }

    @Test("Stylesheet includes design system color tokens")
    func colorTokens() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains("--color-primary"))
        #expect(css.contains("--color-secondary"))
        #expect(css.contains("--color-accent"))
        #expect(css.contains("--color-background"))
        #expect(css.contains("--color-text"))
        #expect(css.contains("--color-error"))
        #expect(css.contains("--color-success"))
    }

    @Test("Stylesheet includes spacing tokens")
    func spacingTokens() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains("--spacing-1: 4px"))
        #expect(css.contains("--spacing-4: 16px"))
        #expect(css.contains("--spacing-16: 64px"))
    }

    @Test("Stylesheet includes dark mode media query")
    func darkMode() {
        #expect(CSSGenerator.defaultStylesheet.contains("prefers-color-scheme: dark"))
    }

    @Test("Stylesheet includes flexbox utility classes")
    func flexUtilities() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains(".flex { display: flex; }"))
        #expect(css.contains(".flex-col"))
        #expect(css.contains(".flex-row"))
        #expect(css.contains(".flex-grow"))
    }

    @Test("Stylesheet includes gap classes")
    func gapClasses() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains(".gap-1"))
        #expect(css.contains(".gap-4"))
        #expect(css.contains(".gap-16"))
    }

    @Test("Stylesheet includes typography classes")
    func typographyClasses() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains(".font-largeTitle"))
        #expect(css.contains(".font-body"))
        #expect(css.contains(".font-caption"))
    }

    @Test("Stylesheet includes foreground color classes")
    func fgClasses() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains(".fg-primary"))
        #expect(css.contains(".fg-error"))
    }

    @Test("Stylesheet includes background color classes")
    func bgClasses() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains(".bg-primary"))
        #expect(css.contains(".bg-surface"))
    }

    @Test("Stylesheet includes border radius classes")
    func radiusClasses() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains(".rounded-sm"))
        #expect(css.contains(".rounded-full"))
    }

    @Test("Stylesheet includes shadow classes")
    func shadowClasses() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains(".shadow-sm"))
        #expect(css.contains(".shadow-xl"))
    }

    @Test("Stylesheet includes padding utility classes")
    func paddingClasses() {
        let css = CSSGenerator.defaultStylesheet
        #expect(css.contains(".p-4"))
        #expect(css.contains(".px-4"))
        #expect(css.contains(".py-4"))
    }

    @Test("Stylesheet includes divider styling")
    func dividerStyling() {
        #expect(CSSGenerator.defaultStylesheet.contains(".divider"))
    }
}
