import Sparrow

@main
struct MyApp: App {
    init() {}

    var routes: [Route] {
        Page("/") {
            VStack(spacing: 16) {
                Text("Welcome to Sparrow")
                    .font(.largeTitle)
                    .foreground(.primary)
                Text("Edit App.swift to get started.")
                    .foreground(.textSecondary)
            }
            .padding(32)
        }

        Page("/about", title: "About") {
            VStack(spacing: 12) {
                Text("About Sparrow")
                    .font(.title)
                Text("A batteries-included Swift web framework.")
                    .foreground(.textSecondary)
            }
            .padding(32)
        }
    }
}
