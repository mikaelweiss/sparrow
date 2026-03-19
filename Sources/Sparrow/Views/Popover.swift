/// A contextual floating panel anchored to a trigger.
/// On desktop: floating popover. On mobile: bottom sheet.
public struct Popover<Content: View>: View {
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

    public var body: Never { fatalError("Popover should not have body called") }
}

extension Popover: Sendable where Content: Sendable {}
