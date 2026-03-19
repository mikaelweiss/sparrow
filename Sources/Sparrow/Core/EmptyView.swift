/// A view that renders nothing.
public struct EmptyView: View, Sendable {
    public typealias Body = Never
    public init() {}
    public var body: Never { fatalError("EmptyView should not have body called") }
}
