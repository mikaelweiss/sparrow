/// A hover tooltip. Renders to a wrapper `<div>` with a tooltip `<span>`.
/// Desktop-only: hidden on touch devices.
public struct Tooltip<Content: View>: View {
    public typealias Body = Never
    public let text: String
    public let content: Content

    public init(
        _ text: String,
        @ViewBuilder content: () -> Content
    ) {
        self.text = text
        self.content = content()
    }

    public var body: Never { fatalError("Tooltip should not have body called") }
}

extension Tooltip: Sendable where Content: Sendable {}
