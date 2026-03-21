/// Toast notification system matching ShadCN Sonner/Toast.
public struct Toaster: PrimitiveView, Sendable {
    public let toasts: [ToastData]
    public let onDismiss: @Sendable (String) -> Void

    public init(toasts: [ToastData], onDismiss: @escaping @Sendable (String) -> Void) {
        self.toasts = toasts
        self.onDismiss = onDismiss
    }
}

public struct ToastData: Sendable {
    public let id: String
    public let title: String
    public let description: String?
    public let variant: ToastVariant
    public let action: ToastAction?

    public init(id: String, title: String, description: String? = nil, variant: ToastVariant = .default, action: ToastAction? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.variant = variant
        self.action = action
    }
}

public enum ToastVariant: Sendable {
    case `default`, destructive, success

    var cssClass: String {
        switch self {
        case .default: "toast-default"
        case .destructive: "toast-destructive"
        case .success: "toast-success"
        }
    }
}

public struct ToastAction: Sendable {
    public let label: String
    public let action: @Sendable () -> Void
    public init(_ label: String, action: @escaping @Sendable () -> Void) {
        self.label = label
        self.action = action
    }
}
