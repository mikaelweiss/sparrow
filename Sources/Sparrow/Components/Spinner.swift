/// Loading spinner matching ShadCN Spinner.
public struct Spinner: PrimitiveView, Sendable {
    public let size: SpinnerSize
    public init(size: SpinnerSize = .default) { self.size = size }
}

public enum SpinnerSize: Sendable {
    case sm, `default`, lg

    var cssClass: String {
        switch self {
        case .sm: "spinner-sm"
        case .default: "spinner-md"
        case .lg: "spinner-lg"
        }
    }
}
