import Sparrow

struct Counter: View {
    @State var count = 0

    var body: some View {
        HStack(spacing: 16) {
            Button("-") {
                count -= 1
            }
            .clipShape(.circle)
            Text("\(count)")
                .font(.title)
            Button("+") {
                count += 1
            }
            .clipShape(.circle)
        }
    }
}

struct Greeter: View {
    @State var name = ""

    var body: some View {
        VStack(spacing: 12) {
            TextField("Your name", text: $name)
            if !name.isEmpty {
                Text("Hello, \(name)!")
                    .font(.title2)
            }
        }
    }
}

@main
struct DevApp: App {
    init() {}

    var routes: [Route] {
        Page("/") {
            VStack(spacing: 24) {
                Text("Sparrow Dev")
                    .font(.largeTitle)
                Greeter()
                Counter()
            }
            .padding(32)
        }
    }
}
