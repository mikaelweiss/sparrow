/// Empty state placeholder matching ShadCN Empty.
public struct EmptyState<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(spacing: 16) {
            content
        }
        .padding(32)
        .foreground(.mutedForeground)
    }
}

extension EmptyState: Sendable where Content: Sendable {}
