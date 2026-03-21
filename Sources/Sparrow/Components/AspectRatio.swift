/// Aspect ratio container matching ShadCN AspectRatio.
public struct AspectRatio<Content: View>: View {
    let ratio: Double
    let content: Content
    public init(_ ratio: Double = 16.0 / 9.0, @ViewBuilder content: () -> Content) {
        self.ratio = ratio
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
        }
        .aspectRatio(ratio, contentMode: .fill)
    }
}

extension AspectRatio: Sendable where Content: Sendable {}
