/// A two-way reference to a value owned by a parent component.
/// Used by form controls (TextField, Toggle, etc.) to read and write state.
///
/// Also usable as `@Binding` property wrapper in child components:
/// ```swift
/// struct ToggleRow: View {
///     @Binding var isOn: Bool
///     var body: some View { Toggle("Label", isOn: $isOn) }
/// }
/// ```
@propertyWrapper
public struct Binding<Value: Sendable>: Sendable {
    private let _get: @Sendable () -> Value
    private let _set: @Sendable (Value) -> Void

    public init(get: @escaping @Sendable () -> Value, set: @escaping @Sendable (Value) -> Void) {
        self._get = get
        self._set = set
    }

    public var wrappedValue: Value {
        get { _get() }
        nonmutating set { _set(newValue) }
    }

    /// Returns self so `$binding` passes the Binding down to children.
    public var projectedValue: Binding<Value> { self }

    /// Create a constant binding that never changes. Useful for previews and testing.
    public static func constant(_ value: Value) -> Binding<Value> {
        Binding(get: { value }, set: { _ in })
    }
}
