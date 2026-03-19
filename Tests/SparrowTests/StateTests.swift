import Testing
@testable import Sparrow

@Suite("State Management")
struct StateTests {
    // MARK: - StateStorage

    @Test("StateStorage stores and retrieves values")
    func stateStorageBasic() {
        let store = StateStorage()
        store.set("key1", value: 42)
        let result: Int = store.get("key1", default: 0)
        #expect(result == 42)
    }

    @Test("StateStorage returns default when key is missing")
    func stateStorageDefault() {
        let store = StateStorage()
        let result: Int = store.get("missing", default: 99)
        #expect(result == 99)
    }

    @Test("StateStorage overwrites existing values")
    func stateStorageOverwrite() {
        let store = StateStorage()
        store.set("key", value: 1)
        store.set("key", value: 2)
        let result: Int = store.get("key", default: 0)
        #expect(result == 2)
    }

    @Test("StateStorage handles multiple types")
    func stateStorageMultipleTypes() {
        let store = StateStorage()
        store.set("int", value: 42)
        store.set("string", value: "hello")
        store.set("bool", value: true)
        #expect(store.get("int", default: 0) == 42)
        #expect(store.get("string", default: "") == "hello")
        #expect(store.get("bool", default: false) == true)
    }

    // MARK: - @State property wrapper

    @Test("@State returns default value without a StateStorage context")
    func stateDefaultValue() {
        @State var count = 0
        #expect(count == 0)
    }

    @Test("@State reads and writes through StateStorage when context is set")
    func stateReadWrite() {
        let store = StateStorage()
        @State var count = 0
        StateStorage.$current.withValue(store) {
            #expect(count == 0) // default
            count = 5
            #expect(count == 5) // updated
        }
    }

    @Test("@State preserves value across separate withValue calls on the same store")
    func statePersistsAcrossRenders() {
        let store = StateStorage()
        @State var count = 0

        // First "render": set value
        StateStorage.$current.withValue(store) {
            count = 10
        }

        // Second "render": value persists
        StateStorage.$current.withValue(store) {
            #expect(count == 10)
        }
    }

    @Test("Different StateStorage instances have independent state")
    func stateIsolation() {
        let store1 = StateStorage()
        let store2 = StateStorage()
        @State var count = 0

        StateStorage.$current.withValue(store1) {
            count = 100
        }

        StateStorage.$current.withValue(store2) {
            #expect(count == 0) // store2 hasn't been written to
        }

        StateStorage.$current.withValue(store1) {
            #expect(count == 100) // store1 still has the value
        }
    }

    // MARK: - Binding

    @Test("Binding.constant returns a fixed value and ignores writes")
    func bindingConstant() {
        let binding = Binding<Int>.constant(42)
        #expect(binding.wrappedValue == 42)
        binding.wrappedValue = 99
        #expect(binding.wrappedValue == 42)
    }

    @Test("Binding reads and writes through StateStorage")
    func bindingCustom() {
        let store = StateStorage()
        let key = "test-binding"
        store.set(key, value: 0)
        let binding = Binding<Int>(
            get: { store.get(key, default: 0) },
            set: { store.set(key, value: $0) }
        )
        #expect(binding.wrappedValue == 0)
        binding.wrappedValue = 10
        #expect(binding.wrappedValue == 10)
    }

    @Test("Binding projectedValue returns self")
    func bindingProjectedValue() {
        let binding = Binding<String>.constant("hello")
        let projected = binding.projectedValue
        #expect(projected.wrappedValue == "hello")
    }

    // MARK: - @State projectedValue (Binding)

    @Test("@State projectedValue returns a Binding that reads and writes through StateStorage")
    func stateProjectedValue() {
        let store = StateStorage()
        @State var name = "initial"

        StateStorage.$current.withValue(store) {
            let binding = $name
            #expect(binding.wrappedValue == "initial")

            binding.wrappedValue = "updated"
            #expect(name == "updated")
            #expect(binding.wrappedValue == "updated")
        }
    }

    @Test("@State binding persists value across separate render passes")
    func stateBindingPersistence() {
        let store = StateStorage()
        @State var text = ""

        // Simulate first render: user types into a TextField
        StateStorage.$current.withValue(store) {
            let binding = $text
            binding.wrappedValue = "hello"
        }

        // Simulate second render: value should persist
        StateStorage.$current.withValue(store) {
            #expect(text == "hello")
        }
    }

    @Test("@State binding works when called from event handler context")
    func stateBindingInEventHandler() {
        let store = StateStorage()
        @State var count = 0

        // Simulate: during rendering, capture a binding in a value handler closure
        var capturedHandler: ((String) -> Void)?
        StateStorage.$current.withValue(store) {
            let binding = $count
            capturedHandler = { newValue in
                if let intVal = Int(newValue) {
                    binding.wrappedValue = intVal
                }
            }
        }

        // Simulate: event arrives, handler called within state context
        StateStorage.$current.withValue(store) {
            capturedHandler?("42")
            #expect(count == 42)
        }
    }
}
