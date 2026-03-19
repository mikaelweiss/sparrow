/// A searchable selection control. Renders to an `<input>` with a `<datalist>`.
public struct Combobox: PrimitiveView, Sendable {
    public let label: String
    public let text: String
    public let options: [ComboboxOption]

    public init(_ label: String, text: String, options: [ComboboxOption]) {
        self.label = label
        self.text = text
        self.options = options
    }
}

public struct ComboboxOption: Sendable {
    public let value: String
    public let label: String

    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }
}
