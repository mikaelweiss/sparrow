/// An increment/decrement control. Renders to paired buttons with a value display.
public struct Stepper: PrimitiveView, Sendable {
    public let label: String
    public let value: Int
    public let range: ClosedRange<Int>
    public let step: Int
    public let onIncrement: @Sendable () -> Void
    public let onDecrement: @Sendable () -> Void

    public init(
        _ label: String,
        value: Int,
        in range: ClosedRange<Int> = 0...100,
        step: Int = 1,
        onIncrement: @escaping @Sendable () -> Void = {},
        onDecrement: @escaping @Sendable () -> Void = {}
    ) {
        self.label = label
        self.value = value
        self.range = range
        self.step = step
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }
}
