/// Generic list item matching ShadCN Item.
public struct Item<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack(spacing: 8) {
            content
        }
        .padding(8)
    }
}

extension Item: Sendable where Content: Sendable {}
