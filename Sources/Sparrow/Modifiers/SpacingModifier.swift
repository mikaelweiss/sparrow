/// Edge specification for padding/margin.
public enum Edge: Sendable {
    case top, bottom, leading, trailing
    case horizontal, vertical
    case all
}

/// A padding amount — either a fixed pixel value or `.infinity` to fill available space.
public enum PaddingValue: Sendable, ExpressibleByIntegerLiteral {
    case fixed(Int)
    case infinity

    public init(integerLiteral value: Int) {
        self = .fixed(value)
    }
}

public struct PaddingModifier: ViewModifier, Sendable {
    public let edge: Edge
    public let value: PaddingValue
    public var createsLayer: Bool { true }

    public var cssClasses: [String] {
        switch value {
        case .fixed(let px):
            let token = spacingToken(px)
            switch edge {
            case .all: return ["p-\(token)"]
            case .horizontal: return ["px-\(token)"]
            case .vertical: return ["py-\(token)"]
            case .top: return ["pt-\(token)"]
            case .bottom: return ["pb-\(token)"]
            case .leading: return ["pl-\(token)"]
            case .trailing: return ["pr-\(token)"]
            }
        case .infinity:
            switch edge {
            case .all: return ["m-auto"]
            case .horizontal: return ["mx-auto"]
            case .vertical: return ["my-auto"]
            case .top: return ["mt-auto"]
            case .bottom: return ["mb-auto"]
            case .leading: return ["ml-auto"]
            case .trailing: return ["mr-auto"]
            }
        }
    }

    public var inlineStyles: [String: String] { [:] }
}

/// Map pixel values to spacing tokens.
func spacingToken(_ px: Int) -> String {
    switch px {
    case 0: "0"
    case 2: "0_5"
    case 4: "1"
    case 6: "1_5"
    case 8: "2"
    case 10: "2_5"
    case 12: "3"
    case 14: "3_5"
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
        modifier(PaddingModifier(edge: .all, value: .fixed(value)))
    }

    public func padding(_ edge: Edge, _ value: PaddingValue) -> ModifiedView<Self, PaddingModifier> {
        modifier(PaddingModifier(edge: edge, value: value))
    }
}
