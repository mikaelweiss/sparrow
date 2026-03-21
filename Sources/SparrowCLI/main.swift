import ArgumentParser
import SparrowCLICore

@main
struct SparrowCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sparrow",
        abstract: "Sparrow — a Swift web platform",
        subcommands: [Serve.self, Build.self, New.self, Preview.self],
        defaultSubcommand: Serve.self
    )
}
