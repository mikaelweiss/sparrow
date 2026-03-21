import Sparrow

@main
struct DevApp: App {
    init() {}

    var iconSet: IconSet { .lucide }

    var routes: [Route] {
        Page("/") {
            Home()
        }
    }
}

struct Home: View {
    @State var count = 0

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            VStack(spacing: 16) {
                Icon("bird")
                    .font(.largeTitle)
                    .foreground(.accent)

                Text("Welcome to Sparrow!")
                    .font(.largeTitle)
                    .bold()

                Text("Simplicity for the web.")
                    .font(.title3)
                    .foreground(.textSecondary)
            }

            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Button("-") { count -= 1 }
                    Text("\(count)").font(.title)
                    Button("+") { count += 1 }
                }
            }
            .padding(24)
            .background(.surface)
            .cornerRadius(.lg)
            Spacer()
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    Link("Docs", url: "https://sparrow.dev/docs")
                    Spacer()
                    Link("GitHub", url: "https://github.com/code-puppies/sparrow")
                }
                .font(.callout)
            }

            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
