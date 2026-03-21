/// Carousel matching ShadCN Carousel.
public struct Carousel<Content: View>: View {
    let orientation: CarouselOrientation
    let content: Content
    public init(orientation: CarouselOrientation = .horizontal, @ViewBuilder content: () -> Content) {
        self.orientation = orientation
        self.content = content()
    }

    public var body: some View {
        VStack {
            content
        }
        .accessibilityRole(.region)
    }
}

public struct CarouselContent<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack(spacing: 16) {
            content
        }
    }
}

public struct CarouselItem<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        VStack {
            content
        }
    }
}

/// Carousel navigation — PrimitiveView because it registers a click handler.
public struct CarouselPrevious: PrimitiveView, Sendable {
    public let action: @Sendable () -> Void
    public init(action: @escaping @Sendable () -> Void) { self.action = action }
}

public struct CarouselNext: PrimitiveView, Sendable {
    public let action: @Sendable () -> Void
    public init(action: @escaping @Sendable () -> Void) { self.action = action }
}

public enum CarouselOrientation: Sendable { case horizontal, vertical }

extension Carousel: Sendable where Content: Sendable {}
extension CarouselContent: Sendable where Content: Sendable {}
extension CarouselItem: Sendable where Content: Sendable {}
