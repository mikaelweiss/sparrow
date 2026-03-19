import Testing
@testable import Sparrow

@Suite("ViewBuilder")
struct ViewBuilderTests {

    @Test("buildBlock with no content produces EmptyView")
    func emptyBlock() {
        @ViewBuilder var view: some View { }
        #expect(view is EmptyView)
    }

    @Test("buildBlock with single view returns that view directly")
    func singleChild() {
        @ViewBuilder var view: some View { Text("solo") }
        let text = view as! Text
        #expect(text.content == "solo")
    }

    @Test("buildBlock with multiple views produces TupleView")
    func multipleChildren() {
        @ViewBuilder var view: some View {
            Text("one")
            Text("two")
        }
        #expect(view is TupleView<(Text, Text)>)
    }

    @Test("buildOptional with nil produces EmptyView branch")
    func optionalNil() {
        let show = false
        @ViewBuilder var view: some View {
            if show {
                Text("visible")
            }
        }
        let renderer = HTMLRenderer()
        let html = renderer.render(view)
        #expect(!html.contains("visible"))
    }

    @Test("buildOptional with value produces the view")
    func optionalPresent() {
        let show = true
        @ViewBuilder var view: some View {
            if show {
                Text("visible")
            }
        }
        let renderer = HTMLRenderer()
        let html = renderer.render(view)
        #expect(html.contains("visible"))
    }

    @Test("buildEither handles if/else branches")
    func ifElse() {
        let condition = false
        @ViewBuilder var view: some View {
            if condition {
                Text("true branch")
            } else {
                Text("false branch")
            }
        }
        let renderer = HTMLRenderer()
        let html = renderer.render(view)
        #expect(html.contains("false branch"))
        #expect(!html.contains("true branch"))
    }
}
