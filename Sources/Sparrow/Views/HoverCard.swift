/// A card that appears on hover. Desktop-only: hidden on touch devices.
public struct HoverCard<Trigger: View, Content: View>: View {
    public typealias Body = Never
    public let trigger: Trigger
    public let content: Content

    public init(
        @ViewBuilder trigger: () -> Trigger,
        @ViewBuilder content: () -> Content
    ) {
        self.trigger = trigger()
        self.content = content()
    }

    public var body: Never { fatalError("HoverCard should not have body called") }
}

extension HoverCard: Sendable where Trigger: Sendable, Content: Sendable {}
