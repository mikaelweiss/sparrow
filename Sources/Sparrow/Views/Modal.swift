/// A modal dialog overlay.
///
/// Uses client runtime primitives:
/// - FocusTrap: traps Tab cycling within the dialog
/// - DismissableLayer: Escape key and outside click dismiss
/// - Presence: enter/exit animations
public struct Modal<Content: View>: View {
    public typealias Body = Never
    public let isPresented: Bool
    /// Optional binding for dismiss support. When provided, Escape/outside-click
    /// sets this to false, which triggers a server re-render that removes the modal.
    let isPresentedBinding: Binding<Bool>?
    public let content: Content

    public init(
        isPresented: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented
        self.isPresentedBinding = nil
        self.content = content()
    }

    /// Binding-based initializer — enables dismiss on Escape / outside click.
    public init(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented.wrappedValue
        self.isPresentedBinding = isPresented
        self.content = content()
    }

    public var body: Never { fatalError("Modal should not have body called") }
}

extension Modal: Sendable where Content: Sendable {}
