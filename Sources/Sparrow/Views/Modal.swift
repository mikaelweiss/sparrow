/// A modal overlay. Renders to `<dialog>`.
public struct Modal<Content: View>: View {
    public typealias Body = Never
    public let isPresented: Bool
    public let content: Content

    public init(
        isPresented: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented
        self.content = content()
    }

    public var body: Never { fatalError("Modal should not have body called") }
}

extension Modal: Sendable where Content: Sendable {}
