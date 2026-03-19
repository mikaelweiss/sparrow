import Testing
@testable import Sparrow

@Suite("HTMLRenderer")
struct HTMLRendererTests {
    let renderer = HTMLRenderer()

    // MARK: - Primitive rendering

    @Test("Text renders as <p> by default")
    func textDefaultTag() {
        let html = renderer.render(Text("Hello"))
        #expect(html.contains("<p>"))
        #expect(html.contains("Hello"))
        #expect(html.contains("</p>"))
    }

    @Test("Text escapes HTML special characters")
    func textEscaping() {
        let html = renderer.render(Text("<script>alert('xss')</script>"))
        #expect(html.contains("&lt;script&gt;"))
        #expect(!html.contains("<script>"))
    }

    @Test("Spacer renders as div with flex-grow class")
    func spacerRendering() {
        let html = renderer.render(Spacer())
        #expect(html.contains("flex-grow"))
        #expect(html.contains("<div"))
    }

    @Test("Divider renders as <hr> with divider class")
    func dividerRendering() {
        let html = renderer.render(Divider())
        #expect(html.contains("<hr"))
        #expect(html.contains("divider"))
    }

    @Test("EmptyView renders as empty string")
    func emptyViewRendering() {
        let html = renderer.render(EmptyView())
        #expect(html == "")
    }

    // MARK: - VStack rendering

    @Test("VStack renders as flex-col div")
    func vstackRendering() {
        let html = renderer.render(VStack { Text("child") })
        #expect(html.contains("flex"))
        #expect(html.contains("flex-col"))
        #expect(html.contains("child"))
    }

    @Test("VStack with spacing adds gap class")
    func vstackSpacing() {
        let html = renderer.render(VStack(spacing: 16) { Text("child") })
        #expect(html.contains("gap-4"))
    }

    @Test("VStack with leading alignment uses items-start")
    func vstackAlignment() {
        let html = renderer.render(VStack(alignment: .leading) { Text("child") })
        #expect(html.contains("items-start"))
    }

    // MARK: - HStack rendering

    @Test("HStack renders as flex-row div")
    func hstackRendering() {
        let html = renderer.render(HStack { Text("child") })
        #expect(html.contains("flex"))
        #expect(html.contains("flex-row"))
        #expect(html.contains("child"))
    }

    @Test("HStack with spacing adds gap class")
    func hstackSpacing() {
        let html = renderer.render(HStack(spacing: 8) { Text("child") })
        #expect(html.contains("gap-2"))
    }

    @Test("HStack with bottom alignment uses items-end")
    func hstackAlignment() {
        let html = renderer.render(HStack(alignment: .bottom) { Text("child") })
        #expect(html.contains("items-end"))
    }

    // MARK: - Multiple children

    @Test("Multiple children in a stack are all rendered")
    func multipleChildren() {
        let html = renderer.render(VStack {
            Text("first")
            Text("second")
            Text("third")
        })
        #expect(html.contains("first"))
        #expect(html.contains("second"))
        #expect(html.contains("third"))
    }

    // MARK: - Nested views

    @Test("Nested stacks render correctly")
    func nestedStacks() {
        let html = renderer.render(VStack {
            HStack {
                Text("left")
                Text("right")
            }
            Text("below")
        })
        #expect(html.contains("flex-col"))
        #expect(html.contains("flex-row"))
        #expect(html.contains("left"))
        #expect(html.contains("right"))
        #expect(html.contains("below"))
    }

    // MARK: - ConditionalView rendering

    @Test("ConditionalView.first renders the first view")
    func conditionalFirstRendering() {
        let view: ConditionalView<Text, EmptyView> = .first(Text("shown"))
        let html = renderer.render(view)
        #expect(html.contains("shown"))
    }

    @Test("ConditionalView.second renders the second view")
    func conditionalSecondRendering() {
        let view: ConditionalView<Text, Text> = .second(Text("other"))
        let html = renderer.render(view)
        #expect(html.contains("other"))
    }

    // MARK: - Custom views

    @Test("Custom view with body is resolved and rendered")
    func customView() {
        struct Greeting: View {
            var body: some View {
                VStack {
                    Text("Hello")
                    Text("World")
                }
            }
        }
        let html = renderer.render(Greeting())
        #expect(html.contains("Hello"))
        #expect(html.contains("World"))
        #expect(html.contains("flex-col"))
    }
}
