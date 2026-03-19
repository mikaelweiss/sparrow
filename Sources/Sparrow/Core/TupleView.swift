/// A view that holds multiple child views from a ViewBuilder block.
public struct TupleView<T>: View {
    public typealias Body = Never
    public let value: T

    public init(value: T) {
        self.value = value
    }

    public var body: Never { fatalError("TupleView should not have body called") }
}

extension TupleView: Sendable where T: Sendable {}
