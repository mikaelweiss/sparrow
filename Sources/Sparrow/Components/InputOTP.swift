/// One-time password input matching ShadCN InputOTP.
public struct InputOTP: PrimitiveView, Sendable {
    public let value: Binding<String>
    public let maxLength: Int
    public let onComplete: (@Sendable (String) -> Void)?

    public init(value: Binding<String>, maxLength: Int = 6, onComplete: (@Sendable (String) -> Void)? = nil) {
        self.value = value
        self.maxLength = maxLength
        self.onComplete = onComplete
    }
}
