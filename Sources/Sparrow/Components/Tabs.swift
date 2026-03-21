/// Tabs component matching ShadCN Tabs.
public struct Tabs<Content: View>: View {
    let selection: Binding<String>
    let content: Content
    public init(selection: Binding<String>, @ViewBuilder content: () -> Content) {
        self.selection = selection
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
    }
}

/// Tab list container — uses roving focus for keyboard navigation.
public struct TabsList<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        HStack(spacing: 4) {
            content
        }
        .padding(4)
        .frame(height: 40)
        .cornerRadius(.md)
        .background(.muted)
        .foreground(.mutedForeground)
        .accessibilityRole(.tablist)
        .rovingFocus(.horizontal)
    }
}

/// Individual tab trigger — PrimitiveView because it registers a click handler.
public struct TabsTrigger: PrimitiveView, Sendable {
    public let value: String
    public let label: String
    public let isSelected: Bool
    public let onSelect: @Sendable () -> Void
    public init(_ label: String, value: String, isSelected: Bool, onSelect: @escaping @Sendable () -> Void) {
        self.value = value
        self.label = label
        self.isSelected = isSelected
        self.onSelect = onSelect
    }
}

/// Tab content panel — only renders when active.
public struct TabsContent<Content: View>: View {
    let value: String
    let isActive: Bool
    let content: Content
    public init(value: String, isActive: Bool, @ViewBuilder content: () -> Content) {
        self.value = value
        self.isActive = isActive
        self.content = content()
    }

    @ViewBuilder
    public var body: some View {
        if isActive {
            VStack(alignment: .leading) {
                content
            }
            .padding(.top, 8)
        }
    }
}

extension Tabs: Sendable where Content: Sendable {}
extension TabsList: Sendable where Content: Sendable {}
extension TabsContent: Sendable where Content: Sendable {}
