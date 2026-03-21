/// A temporary notification. Composes a styled Text with position fixed.
///
/// Matches shadcn Sonner-style toasts.
public struct Toast: View, Sendable {
    public let message: String
    public let variant: ToastVariant

    public init(_ message: String, variant: ToastVariant = .default) {
        self.message = message
        self.variant = variant
    }

    public var body: some View {
        Text(message)
            .modifier(ToastStyleModifier(variant: variant))
    }
}

public enum ToastVariant: Sendable {
    case `default`
    case info
    case success
    case warning
    case error

    var cssClasses: [String] {
        switch self {
        case .default: ["toast"]
        case .info: ["toast", "toast-info"]
        case .success: ["toast", "toast-success"]
        case .warning: ["toast", "toast-warning"]
        case .error: ["toast", "toast-error"]
        }
    }
}

struct ToastStyleModifier: ViewModifier, Sendable {
    let variant: ToastVariant
    var cssClasses: [String] { variant.cssClasses }
    var inlineStyles: [String: String] { [:] }
    var createsLayer: Bool { true }
}
