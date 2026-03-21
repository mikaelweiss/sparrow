/// ToggleGroup matching ShadCN ToggleGroup.
public struct ToggleGroup<Content: View>: View {
    let type: ToggleGroupType
    let content: Content
    public init(type: ToggleGroupType = .single, @ViewBuilder content: () -> Content) {
        self.type = type
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 4) {
            content
        }
        .cornerRadius(.md)
        .accessibilityRole(.group)
        .rovingFocus(.horizontal)
    }
}

public enum ToggleGroupType: Sendable { case single, multiple }

/// Individual toggle item — PrimitiveView because it registers a click handler.
public struct ToggleGroupItem: PrimitiveView, Sendable {
    public let value: String
    public let label: String
    public let isSelected: Bool
    public let onToggle: @Sendable () -> Void
    public init(_ label: String, value: String, isSelected: Bool, onToggle: @escaping @Sendable () -> Void) {
        self.value = value
        self.label = label
        self.isSelected = isSelected
        self.onToggle = onToggle
    }
}

extension ToggleGroup: Sendable where Content: Sendable {}
