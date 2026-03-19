/// A level/capacity indicator. Renders to a styled `<meter>` element.
public struct Gauge: PrimitiveView, Sendable {
    public let value: Double
    public let range: ClosedRange<Double>
    public let label: String

    public init(
        _ label: String = "",
        value: Double,
        in range: ClosedRange<Double> = 0...1
    ) {
        self.label = label
        self.value = value
        self.range = range
    }
}
