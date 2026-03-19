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
}
