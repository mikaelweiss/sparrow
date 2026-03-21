public struct AccessibilityLabelModifier: ViewModifier, Sendable {
    public let label: String
    public var htmlAttributes: [String: String] { ["aria-label": label] }
}

extension View {
    public func accessibilityLabel(_ label: String) -> ModifiedView<Self, AccessibilityLabelModifier> {
        modifier(AccessibilityLabelModifier(label: label))
    }
}

public struct AccessibilityHintModifier: ViewModifier, Sendable {
    public let hint: String
    public var htmlAttributes: [String: String] { ["title": hint] }
}

extension View {
    public func accessibilityHint(_ hint: String) -> ModifiedView<Self, AccessibilityHintModifier> {
        modifier(AccessibilityHintModifier(hint: hint))
    }
}

public struct AccessibilityHiddenModifier: ViewModifier, Sendable {
    public let hidden: Bool
    public var htmlAttributes: [String: String] { ["aria-hidden": hidden ? "true" : "false"] }
}

extension View {
    public func accessibilityHidden(_ hidden: Bool = true) -> ModifiedView<Self, AccessibilityHiddenModifier> {
        modifier(AccessibilityHiddenModifier(hidden: hidden))
    }
}

public enum AccessibilityRole: Sendable {
    case button, link, heading, image, list, listItem
    case tab, tabPanel, navigation, main, banner
    case complementary, contentInfo, form, search
    case alert, dialog, status, progressbar, none

    var ariaValue: String {
        switch self {
        case .button: "button"
        case .link: "link"
        case .heading: "heading"
        case .image: "image"
        case .list: "list"
        case .listItem: "listitem"
        case .tab: "tab"
        case .tabPanel: "tabpanel"
        case .navigation: "navigation"
        case .main: "main"
        case .banner: "banner"
        case .complementary: "complementary"
        case .contentInfo: "contentinfo"
        case .form: "form"
        case .search: "search"
        case .alert: "alert"
        case .dialog: "dialog"
        case .status: "status"
        case .progressbar: "progressbar"
        case .none: "none"
        }
    }
}

public struct AccessibilityRoleModifier: ViewModifier, Sendable {
    public let role: AccessibilityRole
    public var htmlAttributes: [String: String] { ["role": role.ariaValue] }
}

extension View {
    public func accessibilityRole(_ role: AccessibilityRole) -> ModifiedView<Self, AccessibilityRoleModifier> {
        modifier(AccessibilityRoleModifier(role: role))
    }
}

public struct AccessibilityValueModifier: ViewModifier, Sendable {
    public let value: String
    public var htmlAttributes: [String: String] { ["aria-valuetext": value] }
}

extension View {
    public func accessibilityValue(_ value: String) -> ModifiedView<Self, AccessibilityValueModifier> {
        modifier(AccessibilityValueModifier(value: value))
    }
}

public struct AccessibilityIdentifierModifier: ViewModifier, Sendable {
    public let identifier: String
    public var htmlAttributes: [String: String] { ["data-testid": identifier] }
}

extension View {
    public func accessibilityIdentifier(_ identifier: String) -> ModifiedView<Self, AccessibilityIdentifierModifier> {
        modifier(AccessibilityIdentifierModifier(identifier: identifier))
    }
}

public struct AccessibilitySortPriorityModifier: ViewModifier, Sendable {
    public let priority: Double
    public var htmlAttributes: [String: String] { ["tabindex": "\(Int(priority))"] }
}

extension View {
    public func accessibilitySortPriority(_ priority: Double) -> ModifiedView<Self, AccessibilitySortPriorityModifier> {
        modifier(AccessibilitySortPriorityModifier(priority: priority))
    }
}

public enum AccessibilityChildBehavior: Sendable {
    case combine, contain, ignore
}

public struct AccessibilityElementModifier: ViewModifier, Sendable {
    public let children: AccessibilityChildBehavior

    public var htmlAttributes: [String: String] {
        switch children {
        case .combine: ["role": "group"]
        case .contain: [:]
        case .ignore: ["aria-hidden": "true"]
        }
    }
}

extension View {
    public func accessibilityElement(children: AccessibilityChildBehavior = .ignore) -> ModifiedView<Self, AccessibilityElementModifier> {
        modifier(AccessibilityElementModifier(children: children))
    }
}

public struct LabelsHiddenModifier: ViewModifier, Sendable {
    public var cssClasses: [String] { ["sr-only-labels"] }
}

extension View {
    public func labelsHidden() -> ModifiedView<Self, LabelsHiddenModifier> {
        modifier(LabelsHiddenModifier())
    }
}
