/// Skeleton loading placeholder matching ShadCN Skeleton.
public struct Skeleton: PrimitiveView, Sendable {
    public let width: String?
    public let height: String?
    public let rounded: Bool

    public init(width: String? = nil, height: String? = nil, rounded: Bool = false) {
        self.width = width
        self.height = height
        self.rounded = rounded
    }
}
