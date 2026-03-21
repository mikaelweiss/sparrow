/// Custom select dropdown matching ShadCN Select.
public struct SelectMenu: PrimitiveView, Sendable {
    public let selection: Binding<String>
    public let placeholder: String
    public let isOpen: Bool
    public let onToggle: @Sendable () -> Void
    public let onDismiss: @Sendable () -> Void
    public let options: [SelectMenuOption]

    public init(selection: Binding<String>, placeholder: String = "Select...", isOpen: Bool, onToggle: @escaping @Sendable () -> Void, onDismiss: @escaping @Sendable () -> Void, options: [SelectMenuOption]) {
        self.selection = selection
        self.placeholder = placeholder
        self.isOpen = isOpen
        self.onToggle = onToggle
        self.onDismiss = onDismiss
        self.options = options
    }
}

public struct SelectMenuOption: Sendable {
    public let label: String
    public let value: String
    public init(_ label: String, value: String) {
        self.label = label
        self.value = value
    }
}
