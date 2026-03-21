/// A radio button group matching ShadCN RadioGroup.
public struct RadioGroup: PrimitiveView, Sendable {
    let selection: Binding<String>
    let options: [RadioOption]
    let orientation: Orientation

    public enum Orientation: Sendable { case vertical, horizontal }

    public init(selection: Binding<String>, orientation: Orientation = .vertical, options: [RadioOption]) {
        self.selection = selection
        self.options = options
        self.orientation = orientation
    }
}

public struct RadioOption: Sendable {
    public let label: String
    public let value: String

    public init(_ label: String, value: String) {
        self.label = label
        self.value = value
    }
}
