/// Shape options for `.clipShape()`.
public enum ClipShape: Sendable {
    case circle
    case capsule
}

public struct ClipShapeModifier: ViewModifier, Sendable {
    public let shape: ClipShape
    public var createsLayer: Bool { true }

    public var cssClasses: [String] {
        switch shape {
        case .circle: ["clip-circle"]
        case .capsule: ["rounded-full"]
        }
    }
}

extension View {
    public func clipShape(_ shape: ClipShape) -> ModifiedView<Self, ClipShapeModifier> {
        modifier(ClipShapeModifier(shape: shape))
    }
}
