import ArgumentParser
import SparrowCLICore

@main
struct KilnCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "kln",
        abstract: "Sparrow — a batteries-included Swift web framework (kiln shortcut)",
        subcommands: [Run.self, Build.self, New.self],
        defaultSubcommand: Run.self
    )
}
