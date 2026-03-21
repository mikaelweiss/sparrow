public enum SearchPlacement: Sendable {
    case automatic, toolbar, sidebar, navigationBarDrawer

    var cssClass: String {
        switch self {
        case .automatic: "search-auto"
        case .toolbar: "search-toolbar"
        case .sidebar: "search-sidebar"
        case .navigationBarDrawer: "search-drawer"
        }
    }
}

public struct SearchableModifier: ViewModifier, Sendable {
    public let prompt: String
    public let placement: SearchPlacement

    public var cssClasses: [String] { ["searchable", placement.cssClass] }

    public var htmlAttributes: [String: String] {
        ["data-sparrow-search": "true", "data-sparrow-search-prompt": prompt]
    }

    public var createsLayer: Bool { true }
}

extension View {
    public func searchable(prompt: String = "Search", placement: SearchPlacement = .automatic) -> ModifiedView<Self, SearchableModifier> {
        modifier(SearchableModifier(prompt: prompt, placement: placement))
    }
}
