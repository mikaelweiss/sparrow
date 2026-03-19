/// Edge specification for padding/margin.
public enum Edge: Sendable {
    case top, bottom, leading, trailing
    case horizontal, vertical
    case all
}

public struct PaddingModifier: ViewModifier, Sendable {
    public let edge: Edge
    public let value: Int

    public var cssClasses: [String] {
        let token = spacingToken(value)
        switch edge {
        case .all: return ["p-\(token)"]
        case .horizontal: return ["px-\(token)"]
        case .vertical: return ["py-\(token)"]
        case .top: return ["pt-\(token)"]
        case .bottom: return ["pb-\(token)"]
        case .leading: return ["pl-\(token)"]
        case .trailing: return ["pr-\(token)"]
        }
    }

    public var inlineStyles: [String: String] { [:] }
}

/// Map pixel values to spacing tokens.
func spacingToken(_ px: Int) -> String {
    switch px {
    case 0: "0"
    case 4: "1"
    case 8: "2"
    case 12: "3"
    case 16: "4"
    case 20: "5"
    case 24: "6"
    case 32: "8"
    case 40: "10"
    case 48: "12"
    case 64: "16"
    default: "[\(px)]"
    }
}

extension View {
    public func padding(_ value: Int) -> ModifiedView<Self, PaddingModifier> {
        modifier(PaddingModifier(edge: .all, value: value))
    }

    public func padding(_ edge: Edge, _ value: Int) -> ModifiedView<Self, PaddingModifier> {
        modifier(PaddingModifier(edge: edge, value: value))
    }
}
