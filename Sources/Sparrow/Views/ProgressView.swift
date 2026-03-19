/// A progress indicator. Renders to `<progress>`.
public struct ProgressView: PrimitiveView, Sendable {
    public let value: Double?
    public let total: Double

    /// Creates a determinate progress view.
    public init(value: Double, total: Double = 1.0) {
        self.value = value
        self.total = total
    }

    /// Creates an indeterminate progress view (spinner).
    public init() {
        self.value = nil
        self.total = 1.0
    }
}
