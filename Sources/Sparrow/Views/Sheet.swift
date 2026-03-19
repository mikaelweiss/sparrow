/// A slide-in sheet overlay. Renders to a `<div>` with slide-in animation.
public struct Sheet<Content: View>: View {
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

    public var body: Never { fatalError("Sheet should not have body called") }
}

extension Sheet: Sendable where Content: Sendable {}
