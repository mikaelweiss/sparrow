/// A card container with surface styling. Renders to a styled `<div>`.
///
/// Matches shadcn Card with optional sub-components:
/// CardHeader, CardTitle, CardDescription, CardContent, CardFooter
public struct Card<Content: View>: View {
    public typealias Body = Never
    public let content: Content

    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    public var body: Never { fatalError("Card should not have body called") }
}

extension Card: Sendable where Content: Sendable {}

// MARK: - Card sub-components (composite views)

/// Header area of a Card. Composes as a VStack with card-header styling.
public struct CardHeader<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
        }
        .modifier(CardHeaderStyleModifier())
    }
}

extension CardHeader: Sendable where Content: Sendable {}

/// Title text within a CardHeader.
public struct CardTitle: View, Sendable {
    public let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.headline)
            .modifier(CardTitleStyleModifier())
    }
}

/// Description text within a CardHeader.
public struct CardDescription: View, Sendable {
    public let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .modifier(CardDescriptionStyleModifier())
    }
}

/// Main content area of a Card.
public struct CardContent<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .modifier(CardContentStyleModifier())
    }
}

extension CardContent: Sendable where Content: Sendable {}

/// Footer area of a Card.
public struct CardFooter<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack {
            content
        }
        .modifier(CardFooterStyleModifier())
    }
}

extension CardFooter: Sendable where Content: Sendable {}

// MARK: - Style modifiers

struct CardHeaderStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["card-header"] }
    var createsLayer: Bool { true }
}

struct CardTitleStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["card-title"] }
}

struct CardDescriptionStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["card-description"] }
}

struct CardContentStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["card-content"] }
    var createsLayer: Bool { true }
}

struct CardFooterStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["card-footer"] }
    var createsLayer: Bool { true }
}
