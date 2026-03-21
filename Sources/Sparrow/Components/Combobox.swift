/// Combobox (input + filtered dropdown) matching ShadCN Combobox.
public struct Combobox: PrimitiveView, Sendable {
    public let selection: Binding<String>
    public let search: Binding<String>
    public let placeholder: String
    public let isOpen: Bool
    public let onToggle: @Sendable () -> Void
    public let onDismiss: @Sendable () -> Void
    public let options: [ComboboxOption]

    public init(
        selection: Binding<String>,
        search: Binding<String>,
        placeholder: String = "Search...",
        isOpen: Bool,
        onToggle: @escaping @Sendable () -> Void,
        onDismiss: @escaping @Sendable () -> Void,
        options: [ComboboxOption]
    ) {
        self.selection = selection
        self.search = search
        self.placeholder = placeholder
        self.isOpen = isOpen
        self.onToggle = onToggle
        self.onDismiss = onDismiss
        self.options = options
    }
}

public struct ComboboxOption: Sendable {
    public let label: String
    public let value: String
    public init(_ label: String, value: String) {
        self.label = label
        self.value = value
    }
}
