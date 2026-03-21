public enum ListStyle: Sendable {
    case automatic, plain, inset, insetGrouped, sidebar

    var cssClass: String {
        switch self {
        case .automatic: "list-auto"
        case .plain: "list-plain"
        case .inset: "list-inset"
        case .insetGrouped: "list-inset-grouped"
        case .sidebar: "list-sidebar"
        }
    }
}

public struct ListStyleModifier: ViewModifier, Sendable {
    public let style: ListStyle
    public var cssClasses: [String] { [style.cssClass] }
}

public enum Visibility: Sendable {
    case automatic, visible, hidden
}

public struct ListRowSeparatorModifier: ViewModifier, Sendable {
    public let visibility: Visibility

    public var cssClasses: [String] {
        switch visibility {
        case .automatic: []
        case .visible: ["list-separator-visible"]
        case .hidden: ["list-separator-hidden"]
        }
    }
}

public struct ListRowInsetsModifier: ViewModifier, Sendable {
    public let top: Int
    public let leading: Int
    public let bottom: Int
    public let trailing: Int
    public var createsLayer: Bool { true }

    public var inlineStyles: [String: String] {
        [
            "padding-top": "\(top)px",
            "padding-right": "\(trailing)px",
            "padding-bottom": "\(bottom)px",
            "padding-left": "\(leading)px",
        ]
    }
}

public struct BadgeModifier: ViewModifier, Sendable {
    public let value: String
    public var htmlAttributes: [String: String] { ["data-badge": value] }
}

extension View {
    public func listStyle(_ style: ListStyle) -> ModifiedView<Self, ListStyleModifier> {
        modifier(ListStyleModifier(style: style))
    }

    public func listRowSeparator(_ visibility: Visibility) -> ModifiedView<Self, ListRowSeparatorModifier> {
        modifier(ListRowSeparatorModifier(visibility: visibility))
    }

    public func listRowInsets(top: Int = 0, leading: Int = 0, bottom: Int = 0, trailing: Int = 0) -> ModifiedView<Self, ListRowInsetsModifier> {
        modifier(ListRowInsetsModifier(top: top, leading: leading, bottom: bottom, trailing: trailing))
    }

    public func badge(_ count: Int) -> ModifiedView<Self, BadgeModifier> {
        modifier(BadgeModifier(value: "\(count)"))
    }

    public func badge(_ text: String) -> ModifiedView<Self, BadgeModifier> {
        modifier(BadgeModifier(value: text))
    }
}
