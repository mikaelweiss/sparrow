/// A numeric slider. Renders to `<input type="range">`.
/// Accepts a `Binding<Double>` to round-trip the value from the browser.
public struct Slider: PrimitiveView, Sendable {
    public let value: Binding<Double>
    public let range: ClosedRange<Double>
    public let step: Double

    public init(value: Binding<Double>, in range: ClosedRange<Double> = 0...100, step: Double = 1) {
        self.value = value
        self.range = range
        self.step = step
    }
}
