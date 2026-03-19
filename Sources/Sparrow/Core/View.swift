/// The core View protocol. Every Sparrow component implements this.
public protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

/// Marker protocol for primitive views that render directly to HTML.
/// These don't have a `body` — the renderer handles them directly.
public protocol PrimitiveView: View where Body == Never {}

extension PrimitiveView {
    public var body: Never { fatalError("PrimitiveView should never have body called") }
}

/// Never conforms to View as a terminal type.
extension Never: View {
    public typealias Body = Never
    public var body: Never { fatalError() }
}
