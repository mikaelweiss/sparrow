/// Input with prefix/suffix addons matching ShadCN InputGroup.
public struct InputGroup<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack {
            content
        }
        .cornerRadius(.md)
        .border(.input)
        .background(.background)
    }
}

public struct InputGroupPrefix<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack {
            content
        }
        .padding(.horizontal, 12)
        .foreground(.mutedForeground)
        .border(.input)
    }
}

public struct InputGroupSuffix<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack {
            content
        }
        .padding(.horizontal, 12)
        .foreground(.mutedForeground)
        .border(.input)
    }
}

extension InputGroup: Sendable where Content: Sendable {}
extension InputGroupPrefix: Sendable where Content: Sendable {}
extension InputGroupSuffix: Sendable where Content: Sendable {}
