/// Server-side state owned by a single component. Mutable. Triggers re-render when changed.
///
/// Uses source-location (file + line + column) as a stable key so the same @State declaration
/// always maps to the same slot in the session's state store across re-renders.
@propertyWrapper
public struct State<Value: Sendable>: Sendable {
    let defaultValue: Value
    let key: String

    public init(wrappedValue: Value, file: String = #fileID, line: Int = #line, column: Int = #column) {
        self.defaultValue = wrappedValue
        self.key = "\(file):\(line):\(column)"
    }

    public var wrappedValue: Value {
        get {
            guard let store = StateStorage.current else { return defaultValue }
            return store.get(key, default: defaultValue)
        }
        nonmutating set {
            guard let store = StateStorage.current else { return }
            store.set(key, value: newValue)
        }
    }

    /// Access the binding via `$state`. The returned Binding reads and writes
    /// through StateStorage.current, which is set during rendering and event handling.
    public var projectedValue: Binding<Value> {
        let key = self.key
        let defaultValue = self.defaultValue
        return Binding(
            get: {
                guard let store = StateStorage.current else { return defaultValue }
                return store.get(key, default: defaultValue)
            },
            set: { newValue in
                guard let store = StateStorage.current else { return }
                store.set(key, value: newValue)
            }
        )
    }
}
