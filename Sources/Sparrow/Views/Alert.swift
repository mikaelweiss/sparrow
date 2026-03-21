/// An alert message. Composes a styled VStack with title and optional description.
///
/// Matches shadcn Alert: default and destructive variants.
public struct Alert: View, Sendable {
    public let title: String
    public let message: String
    public let variant: AlertVariant

    public init(title: String, message: String = "", variant: AlertVariant = .default) {
        self.title = title
        self.message = message
        self.variant = variant
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .modifier(AlertTitleStyleModifier())
            if !message.isEmpty {
                Text(message)
                    .modifier(AlertDescriptionStyleModifier())
            }
        }
        .modifier(AlertStyleModifier(variant: variant))
    }
}

public enum AlertVariant: Sendable {
    case `default`
    case destructive
}

struct AlertStyleModifier: ViewModifier, Sendable {
    let variant: AlertVariant
    var cssClasses: [String] {
        switch variant {
        case .default: ["alert"]
        case .destructive: ["alert", "alert-destructive"]
        }
    }
    var inlineStyles: [String: String] { [:] }
    var createsLayer: Bool { true }
    var htmlAttributes: [String: String] { ["role": "alert"] }
}

struct AlertTitleStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["alert-title"] }
    var inlineStyles: [String: String] { [:] }
}

struct AlertDescriptionStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["alert-description"] }
    var inlineStyles: [String: String] { [:] }
}
