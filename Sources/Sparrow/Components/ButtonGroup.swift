/// Button group matching ShadCN ButtonGroup.
public struct ButtonGroup<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack {
            content
        }
    }
}

extension ButtonGroup: Sendable where Content: Sendable {}
