/// A group of mutually exclusive radio options. Renders to `<fieldset>` with `<input type="radio">`.
public struct RadioGroup: PrimitiveView, Sendable {
    public let label: String
    public let selection: String
    public let options: [RadioOption]

    public init(_ label: String, selection: String, options: [RadioOption]) {
        self.label = label
        self.selection = selection
        self.options = options
    }
}

public struct RadioOption: Sendable {
    public let value: String
    public let label: String

    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }
}
