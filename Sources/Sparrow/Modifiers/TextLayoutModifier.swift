public enum TextAlignment: Sendable {
    case leading
    case center
    case trailing

    var cssClass: String {
        switch self {
        case .leading: "text-left"
        case .center: "text-center"
        case .trailing: "text-right"
        }
    }
}

public struct TextAlignmentModifier: ViewModifier, Sendable {
    public let alignment: TextAlignment
    public var cssClasses: [String] { [alignment.cssClass] }
}

public struct LineLimitModifier: ViewModifier, Sendable {
    public let limit: Int?

    public var cssClasses: [String] {
        guard let limit else { return [] }
        return ["line-clamp-\(limit)"]
    }
}

public enum TruncationMode: Sendable {
    case head
    case tail
    case middle
}

public struct TruncationModifier: ViewModifier, Sendable {
    public let mode: TruncationMode
    public var cssClasses: [String] { ["truncate"] }
}

public struct LineSpacingModifier: ViewModifier, Sendable {
    public let spacing: Double

    public var inlineStyles: [String: String] {
        ["line-height": "\(spacing)px"]
    }
}

public struct TextSelectionModifier: ViewModifier, Sendable {
    public let enabled: Bool

    public var cssClasses: [String] {
        [enabled ? "select-text" : "select-none"]
    }
}

public struct BaselineOffsetModifier: ViewModifier, Sendable {
    public let offset: Double

    public var inlineStyles: [String: String] {
        ["vertical-align": "\(offset)px"]
    }
}

extension View {
    public func multilineTextAlignment(_ alignment: TextAlignment) -> ModifiedView<Self, TextAlignmentModifier> {
        modifier(TextAlignmentModifier(alignment: alignment))
    }

    public func lineLimit(_ limit: Int?) -> ModifiedView<Self, LineLimitModifier> {
        modifier(LineLimitModifier(limit: limit))
    }

    public func truncationMode(_ mode: TruncationMode) -> ModifiedView<Self, TruncationModifier> {
        modifier(TruncationModifier(mode: mode))
    }

    public func lineSpacing(_ spacing: Double) -> ModifiedView<Self, LineSpacingModifier> {
        modifier(LineSpacingModifier(spacing: spacing))
    }

    public func textSelection(_ enabled: Bool) -> ModifiedView<Self, TextSelectionModifier> {
        modifier(TextSelectionModifier(enabled: enabled))
    }

    public func baselineOffset(_ offset: Double) -> ModifiedView<Self, BaselineOffsetModifier> {
        modifier(BaselineOffsetModifier(offset: offset))
    }
}
