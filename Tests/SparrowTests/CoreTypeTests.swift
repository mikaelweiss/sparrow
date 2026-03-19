import Testing
@testable import Sparrow

@Suite("Core View Types")
struct CoreTypeTests {

    // MARK: - EmptyView

    @Test("EmptyView exists and conforms to View and Sendable")
    func emptyViewConformance() {
        let view = EmptyView()
        let _: any View = view
        let _: any Sendable = view
    }

    // MARK: - TupleView

    @Test("TupleView stores its value")
    func tupleViewStoresValue() {
        let tuple = TupleView(value: (Text("a"), Text("b")))
        let mirror = Mirror(reflecting: tuple.value)
        #expect(mirror.children.count == 2)
    }

    @Test("TupleView is Sendable when contents are Sendable")
    func tupleViewSendable() {
        let tuple = TupleView(value: (Text("a"), Text("b")))
        let _: any Sendable = tuple
    }

    // MARK: - ConditionalView

    @Test("ConditionalView.first wraps the first view")
    func conditionalFirst() {
        let view: ConditionalView<Text, EmptyView> = .first(Text("hello"))
        if case .first(let text) = view {
            #expect(text.content == "hello")
        } else {
            Issue.record("Expected .first case")
        }
    }

    @Test("ConditionalView.second wraps the second view")
    func conditionalSecond() {
        let view: ConditionalView<Text, EmptyView> = .second(EmptyView())
        if case .second = view {
            // pass
        } else {
            Issue.record("Expected .second case")
        }
    }

    // MARK: - Text

    @Test("Text stores its content string")
    func textContent() {
        let text = Text("Hello, Sparrow!")
        #expect(text.content == "Hello, Sparrow!")
    }

    // MARK: - VStack

    @Test("VStack defaults to center alignment and zero spacing")
    func vstackDefaults() {
        let stack = VStack { Text("child") }
        #expect(stack.alignment == .center)
        #expect(stack.spacing == 0)
    }

    @Test("VStack accepts custom alignment and spacing")
    func vstackCustom() {
        let stack = VStack(alignment: .leading, spacing: 16) { Text("child") }
        #expect(stack.alignment == .leading)
        #expect(stack.spacing == 16)
    }

    // MARK: - HStack

    @Test("HStack defaults to center alignment and zero spacing")
    func hstackDefaults() {
        let stack = HStack { Text("child") }
        #expect(stack.alignment == .center)
        #expect(stack.spacing == 0)
    }

    @Test("HStack accepts custom alignment and spacing")
    func hstackCustom() {
        let stack = HStack(alignment: .top, spacing: 8) { Text("child") }
        #expect(stack.alignment == .top)
        #expect(stack.spacing == 8)
    }

    // MARK: - Alignment CSS classes

    @Test("HorizontalAlignment produces correct CSS classes", arguments: [
        (HorizontalAlignment.leading, "items-start"),
        (HorizontalAlignment.center, "items-center"),
        (HorizontalAlignment.trailing, "items-end"),
    ])
    func horizontalAlignmentCSS(alignment: HorizontalAlignment, expected: String) {
        #expect(alignment.cssClass == expected)
    }

    @Test("VerticalAlignment produces correct CSS classes", arguments: [
        (VerticalAlignment.top, "items-start"),
        (VerticalAlignment.center, "items-center"),
        (VerticalAlignment.bottom, "items-end"),
    ])
    func verticalAlignmentCSS(alignment: VerticalAlignment, expected: String) {
        #expect(alignment.cssClass == expected)
    }
}
