/// A form container with built-in validation. Renders to `<form>`.
public struct Form<Content: View>: View {
    public typealias Body = Never
    public let content: Content

    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    public var body: Never { fatalError("Form should not have body called") }
}

extension Form: Sendable where Content: Sendable {}
