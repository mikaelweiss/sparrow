import Testing
@testable import Sparrow

@Suite("Modifiers")
struct ModifierTests {
    let renderer = HTMLRenderer()

    // MARK: - Font modifier

    @Test("Font modifier adds the correct CSS class")
    func fontClasses() {
        let cases: [(Font, String)] = [
            (.largeTitle, "font-largeTitle"),
            (.title, "font-title"),
            (.title2, "font-title2"),
            (.title3, "font-title3"),
            (.headline, "font-headline"),
            (.body, "font-body"),
            (.callout, "font-callout"),
            (.subheadline, "font-subheadline"),
            (.footnote, "font-footnote"),
            (.caption, "font-caption"),
        ]
        for (font, expected) in cases {
            let modifier = FontModifier(font: font)
            #expect(modifier.cssClasses == [expected])
        }
    }

    @Test("Font modifier changes HTML tag for heading fonts")
    func fontHTMLTags() {
        let html = renderer.render(Text("Title").font(.largeTitle))
        #expect(html.contains("<h1"))
        #expect(html.contains("</h1>"))

        let html2 = renderer.render(Text("Sub").font(.title))
        #expect(html2.contains("<h2"))

        let html3 = renderer.render(Text("Body").font(.body))
        #expect(html3.contains("<p"))
    }

    @Test("Font modifier adds CSS class to rendered output")
    func fontCSSInOutput() {
        let html = renderer.render(Text("styled").font(.headline))
        #expect(html.contains("font-headline"))
    }

    // MARK: - Foreground color modifier

    @Test("Foreground modifier adds fg- class")
    func foregroundColor() {
        let html = renderer.render(Text("colored").foreground(.primary))
        #expect(html.contains("fg-primary"))
    }

    @Test("Foreground with all semantic colors produces correct classes")
    func foregroundAllColors() {
        let cases: [(SemanticColor, String)] = [
            (.primary, "fg-primary"),
            (.secondary, "fg-secondary"),
            (.accent, "fg-accent"),
            (.text, "fg-text"),
            (.textSecondary, "fg-textSecondary"),
            (.textTertiary, "fg-textTertiary"),
            (.error, "fg-error"),
            (.success, "fg-success"),
            (.warning, "fg-warning"),
            (.info, "fg-info"),
        ]
        for (color, expected) in cases {
            let modifier = ForegroundModifier(color: color)
            #expect(modifier.cssClasses == [expected])
        }
    }

    @Test("Foreground with hex color produces bracketed class")
    func foregroundHex() {
        let modifier = ForegroundModifier(color: .hex("#FF0000"))
        #expect(modifier.cssClasses == ["fg-[#FF0000]"])
    }

    // MARK: - Background color modifier

    @Test("Background modifier adds bg- class")
    func backgroundColor() {
        let html = renderer.render(Text("bg").background(.surface))
        #expect(html.contains("bg-surface"))
    }

    // MARK: - Padding modifier

    @Test("Padding modifier with standard token values")
    func paddingTokens() {
        let cases: [(Int, String)] = [
            (0, "p-0"), (4, "p-1"), (8, "p-2"), (12, "p-3"),
            (16, "p-4"), (20, "p-5"), (24, "p-6"), (32, "p-8"),
            (40, "p-10"), (48, "p-12"), (64, "p-16"),
        ]
        for (px, expected) in cases {
            let modifier = PaddingModifier(edge: .all, value: px)
            #expect(modifier.cssClasses == [expected])
        }
    }

    @Test("Padding modifier with non-standard value uses bracket syntax")
    func paddingCustom() {
        let modifier = PaddingModifier(edge: .all, value: 7)
        #expect(modifier.cssClasses == ["p-[7]"])
    }

    @Test("Padding modifier with edge variants")
    func paddingEdges() {
        #expect(PaddingModifier(edge: .horizontal, value: 16).cssClasses == ["px-4"])
        #expect(PaddingModifier(edge: .vertical, value: 16).cssClasses == ["py-4"])
        #expect(PaddingModifier(edge: .top, value: 8).cssClasses == ["pt-2"])
        #expect(PaddingModifier(edge: .bottom, value: 8).cssClasses == ["pb-2"])
        #expect(PaddingModifier(edge: .leading, value: 16).cssClasses == ["pl-4"])
        #expect(PaddingModifier(edge: .trailing, value: 16).cssClasses == ["pr-4"])
    }

    @Test("Padding renders in HTML output")
    func paddingInOutput() {
        let html = renderer.render(Text("padded").padding(16))
        #expect(html.contains("p-4"))
    }

    // MARK: - Corner radius modifier

    @Test("CornerRadius modifier produces correct CSS classes")
    func cornerRadiusClasses() {
        let cases: [(CornerRadius, String)] = [
            (.none, "rounded-none"),
            (.sm, "rounded-sm"),
            (.md, "rounded-md"),
            (.lg, "rounded-lg"),
            (.xl, "rounded-xl"),
            (.xxl, "rounded-2xl"),
            (.full, "rounded-full"),
        ]
        for (radius, expected) in cases {
            let modifier = CornerRadiusModifier(radius: radius)
            #expect(modifier.cssClasses == [expected])
        }
    }

    @Test("Corner radius renders in HTML output")
    func cornerRadiusInOutput() {
        let html = renderer.render(Text("rounded").cornerRadius(.lg))
        #expect(html.contains("rounded-lg"))
    }

    // MARK: - Shadow modifier

    @Test("Shadow modifier produces correct CSS classes")
    func shadowClasses() {
        let cases: [(Shadow, String)] = [
            (.none, "shadow-none"),
            (.sm, "shadow-sm"),
            (.md, "shadow-md"),
            (.lg, "shadow-lg"),
            (.xl, "shadow-xl"),
        ]
        for (shadow, expected) in cases {
            let modifier = ShadowModifier(shadow: shadow)
            #expect(modifier.cssClasses == [expected])
        }
    }

    @Test("Shadow renders in HTML output")
    func shadowInOutput() {
        let html = renderer.render(Text("shadowed").shadow(.md))
        #expect(html.contains("shadow-md"))
    }

    // MARK: - Frame modifier

    @Test("Frame modifier with fixed width and height")
    func frameFixed() {
        let modifier = FrameModifier(width: .fixed(200), height: .fixed(100), maxWidth: nil, minHeight: nil)
        #expect(modifier.inlineStyles["width"] == "200px")
        #expect(modifier.inlineStyles["height"] == "100px")
        #expect(modifier.cssClasses.isEmpty)
    }

    @Test("Frame modifier with infinity dimensions")
    func frameInfinity() {
        let modifier = FrameModifier(width: .infinity, height: nil, maxWidth: nil, minHeight: nil)
        #expect(modifier.inlineStyles["width"] == "100%")
    }

    @Test("Frame modifier with maxWidth and minHeight")
    func frameConstraints() {
        let modifier = FrameModifier(width: nil, height: nil, maxWidth: .fixed(600), minHeight: .fixed(400))
        #expect(modifier.inlineStyles["max-width"] == "600px")
        #expect(modifier.inlineStyles["min-height"] == "400px")
    }

    @Test("Frame renders inline styles in HTML output")
    func frameInOutput() {
        let html = renderer.render(Text("sized").frame(width: 100, height: 50))
        #expect(html.contains("width: 100px"))
        #expect(html.contains("height: 50px"))
    }

    // MARK: - Modifier chaining

    @Test("Multiple modifiers accumulate classes and styles")
    func modifierChaining() {
        let html = renderer.render(
            Text("styled")
                .font(.title)
                .foreground(.primary)
                .padding(16)
                .cornerRadius(.md)
                .shadow(.sm)
        )
        #expect(html.contains("font-title"))
        #expect(html.contains("fg-primary"))
        #expect(html.contains("p-4"))
        #expect(html.contains("rounded-md"))
        #expect(html.contains("shadow-sm"))
    }

    @Test("Modifiers on a stack are applied to the container div")
    func modifiersOnStack() {
        let html = renderer.render(
            VStack {
                Text("child")
            }
            .padding(24)
            .background(.surface)
        )
        #expect(html.contains("p-6"))
        #expect(html.contains("bg-surface"))
    }
}
