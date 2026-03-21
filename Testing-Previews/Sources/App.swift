import Sparrow

@main
struct Testing_Previews: App {
    init() {}

    var routes: [Route] {
        Page("/") {
            AppView()
        }
    }
}

struct AppView: View {
    @State var count = 0
    @State var name = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to Testing-Previews")
                .font(.largeTitle)

            VStack(spacing: 12) {
                TextField("Your name", text: $name)
                if !name.isEmpty {
                    Text("Hello, \(name)!")
                        .font(.title2)
                }
            }
            HStack(spacing: 16) {
                Button("-") { count -= 1 }
                    .clipShape(.circle)
                Text("\(count)")
                    .font(.title)
                Button("+") { count += 1 }
                    .clipShape(.circle)
            }
            Link("sparrowframework.dev", url: "https://sparrowframework.dev")
        }
        .padding(32)
    }
}

#Preview("Testing-Previews", layout: .fullPage) {
    AppView()
}
