public enum SafeAreaEdge: Sendable {
    case top, bottom, leading, trailing, all, horizontal, vertical
}

public struct IgnoresSafeAreaModifier: ViewModifier, Sendable {
    public let edges: SafeAreaEdge

    public var cssClasses: [String] {
        switch edges {
        case .all: ["safe-area-ignore"]
        case .top: ["safe-area-ignore-top"]
        case .bottom: ["safe-area-ignore-bottom"]
        case .leading: ["safe-area-ignore-leading"]
        case .trailing: ["safe-area-ignore-trailing"]
        case .horizontal: ["safe-area-ignore-horizontal"]
        case .vertical: ["safe-area-ignore-vertical"]
        }
    }

    public var createsLayer: Bool { true }
}

extension View {
    public func ignoresSafeArea(_ edges: SafeAreaEdge = .all) -> ModifiedView<Self, IgnoresSafeAreaModifier> {
        modifier(IgnoresSafeAreaModifier(edges: edges))
    }
}
