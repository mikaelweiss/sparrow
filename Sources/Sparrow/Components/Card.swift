/// Card component matching ShadCN Card.
public struct Card<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .cornerRadius(.lg)
        .border(.border)
        .background(.card)
        .foreground(.cardForeground)
        .shadow(.sm)
    }
}

public struct CardHeader<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            content
        }
        .padding(24)
    }
}

public struct CardTitle: View, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.title2)
            .fontWeight(.semibold)
            .lineHeight(1)
            .tracking(-0.025)
    }
}

public struct CardDescription: View, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.body)
            .foreground(.mutedForeground)
    }
}

public struct CardContent<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

public struct CardFooter<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack {
            content
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

extension Card: Sendable where Content: Sendable {}
extension CardHeader: Sendable where Content: Sendable {}
extension CardContent: Sendable where Content: Sendable {}
extension CardFooter: Sendable where Content: Sendable {}
