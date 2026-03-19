import ArgumentParser
import SparrowCLICore

@main
struct SparrowCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sparrow",
        abstract: "Sparrow — a batteries-included Swift web framework",
        subcommands: [Serve.self, Build.self, New.self],
        defaultSubcommand: Serve.self
    )
}
