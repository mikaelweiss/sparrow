/// A selection control. Renders to `<select>` with options.
/// Accepts a `Binding<String>` to round-trip the selected value from the browser.
public struct Picker: PrimitiveView, Sendable {
    public let label: String
    public let selection: Binding<String>
    public let options: [PickerOption]

    public init(_ label: String, selection: Binding<String>, options: [PickerOption]) {
        self.label = label
        self.selection = selection
        self.options = options
    }
}

public struct PickerOption: Sendable {
    public let value: String
    public let label: String

    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }
}
