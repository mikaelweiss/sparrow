/// Alert component matching ShadCN Alert.
public struct Alert<Content: View>: View {
    let variant: AlertVariant
    let content: Content
    public init(variant: AlertVariant = .default, @ViewBuilder content: () -> Content) {
        self.variant = variant
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
        }
        .padding(16)
        .cornerRadius(.lg)
        .border(variant == .destructive ? .error.opacity(0.5) : .border)
        .background(variant == .destructive ? .background : .background)
        .foreground(variant == .destructive ? .error : .text)
        .accessibilityRole(.alert)
    }
}

public enum AlertVariant: Sendable {
    case `default`
    case destructive
}

public struct AlertTitle: View, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.headline)
            .fontWeight(.medium)
            .tracking(-0.025)
    }
}

public struct AlertDescription: View, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.body)
            .opacity(0.9)
    }
}

extension Alert: Sendable where Content: Sendable {}
