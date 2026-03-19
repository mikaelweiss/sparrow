/// A loading placeholder. Renders to a `<div>` with a shimmer animation.
public struct Skeleton: PrimitiveView, Sendable {
    public let shape: SkeletonShape

    public init(_ shape: SkeletonShape = .rectangle) {
        self.shape = shape
    }

    public enum SkeletonShape: Sendable {
        case rectangle
        case circle
        case text(lines: Int)
    }
}
