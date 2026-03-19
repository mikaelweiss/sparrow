/// A horizontal set of mutually exclusive segments. Renders to a segmented button group.
public struct SegmentedControl: PrimitiveView, Sendable {
    public let selection: String
    public let options: [SegmentOption]

    public init(selection: String, options: [SegmentOption]) {
        self.selection = selection
        self.options = options
    }
}

public struct SegmentOption: Sendable {
    public let value: String
    public let label: String

    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }
}
