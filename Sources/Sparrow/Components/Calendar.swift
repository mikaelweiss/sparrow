/// Calendar date picker matching ShadCN Calendar (react-day-picker).
public struct Calendar: PrimitiveView, Sendable {
    public let selectedDate: Binding<String>
    public let month: Binding<String>

    public init(selectedDate: Binding<String>, month: Binding<String>) {
        self.selectedDate = selectedDate
        self.month = month
    }
}
