/// A loading spinner. Composes a styled empty div with CSS animation.
public struct Spinner: View, Sendable {
    public init() {}

    public var body: some View {
        Spacer()
            .modifier(SpinnerStyleModifier())
    }
}

struct SpinnerStyleModifier: ViewModifier, Sendable {
    var cssClasses: [String] { ["spinner"] }
    var inlineStyles: [String: String] { [:] }
    var createsLayer: Bool { true }
}
