/// Form field wrapper matching ShadCN Field (label + control + description + error).
public struct Field<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
    }
}

/// Field description text.
public struct FieldDescription: View, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.body)
            .foreground(.mutedForeground)
    }
}

/// Field error text — PrimitiveView for role="alert" attribute.
public struct FieldError: PrimitiveView, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }
}

extension Field: Sendable where Content: Sendable {}
