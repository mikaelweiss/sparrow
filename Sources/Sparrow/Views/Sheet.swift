/// A slide-in sheet overlay.
///
/// Uses client runtime primitives:
/// - FocusTrap: traps Tab cycling within the sheet
/// - DismissableLayer: Escape key and outside click dismiss
/// - Presence: slide-in/out animations
public struct Sheet<Content: View>: View {
    public typealias Body = Never
    public let isPresented: Bool
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

    public init(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented.wrappedValue
        self.isPresentedBinding = isPresented
        self.content = content()
    }

    public var body: Never { fatalError("Sheet should not have body called") }
}

extension Sheet: Sendable where Content: Sendable {}
