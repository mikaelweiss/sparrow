/// A numeric slider. Renders to `<input type="range">`.
public struct Slider: PrimitiveView, Sendable {
    public let value: Double
    public let range: ClosedRange<Double>
    public let step: Double

    public init(value: Double = 0, in range: ClosedRange<Double> = 0...100, step: Double = 1) {
        self.value = value
        self.range = range
        self.step = step
    }
}
