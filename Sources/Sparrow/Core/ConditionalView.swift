/// A view that represents one of two possible views (from if/else).
public enum ConditionalView<First: View, Second: View>: View {
    case first(First)
    case second(Second)

    public typealias Body = Never
    public var body: Never { fatalError("ConditionalView should not have body called") }
}

extension ConditionalView: Sendable where First: Sendable, Second: Sendable {}
