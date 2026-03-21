/// A styled checkbox matching ShadCN Checkbox.
public struct Checkbox: PrimitiveView, Sendable {
    let isChecked: Binding<Bool>
    let label: String?

    public init(isOn: Binding<Bool>, label: String? = nil) {
        self.isChecked = isOn
        self.label = label
    }
}
