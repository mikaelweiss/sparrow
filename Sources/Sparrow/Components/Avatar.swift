/// Avatar component matching ShadCN Avatar.
/// Container uses clipShape for circular clipping. AvatarImage and AvatarFallback
/// are PrimitiveViews because they render <img> and <span> respectively.
public struct Avatar<Content: View>: View {
    let size: AvatarSize
    let content: Content
    public init(size: AvatarSize = .default, @ViewBuilder content: () -> Content) {
        self.size = size
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
        }
        .frame(width: size.pixels, height: size.pixels)
        .clipShape(.circle)
    }
}

public enum AvatarSize: Sendable {
    case sm, `default`, lg

    var pixels: Int {
        switch self {
        case .sm: 32
        case .default: 40
        case .lg: 48
        }
    }
}

/// Renders to `<img>` — PrimitiveView because Image primitive requires asset names.
public struct AvatarImage: PrimitiveView, Sendable {
    public let src: String
    public let alt: String
    public init(src: String, alt: String = "") {
        self.src = src
        self.alt = alt
    }
}

/// Renders fallback initials — PrimitiveView for specific styling.
public struct AvatarFallback: PrimitiveView, Sendable {
    public let text: String
    public init(_ text: String) { self.text = text }
}

extension Avatar: Sendable where Content: Sendable {}
