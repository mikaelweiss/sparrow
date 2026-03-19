import ArgumentParser
import SparrowCLICore

@main
struct SparrowCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sparrow",
        abstract: "Sparrow — a batteries-included Swift web framework",
        subcommands: [Run.self, Build.self, New.self],
        defaultSubcommand: Run.self
    )
}
