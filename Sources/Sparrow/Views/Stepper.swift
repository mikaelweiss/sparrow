/// An increment/decrement control. Composes Button and Text views.
public struct Stepper: View, Sendable {
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

    public var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .modifier(StepperLabelStyleModifier())
            HStack(spacing: 0) {
                Button("−", variant: .outline, size: .icon, action: onDecrement)
                Text("\(value)")
                    .modifier(StepperValueStyleModifier())
                Button("+", variant: .outline, size: .icon, action: onIncrement)
            }
            .modifier(StepperControlsStyleModifier())
        }
        .modifier(StepperStyleModifier())
    }
}

struct StepperStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["stepper"] }
}

struct StepperLabelStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["stepper-label"] }
}

struct StepperControlsStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["stepper-controls"] }
}

struct StepperValueStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["stepper-value"] }
}
